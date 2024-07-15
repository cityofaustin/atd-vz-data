#!/usr/bin/python3

import os
import re
import time
import hashlib
import datetime
import glob
import tempfile
import magic
from subprocess import Popen, PIPE

import shutil
import boto3
import botocore
import sysrsync
import psycopg2
import psycopg2.extras
import onepasswordconnectsdk
from sshtunnel import SSHTunnelForwarder
from onepasswordconnectsdk.client import Client, new_client

import lib.mappings as mappings
import lib.sql as util
import lib.graphql as graphql
from lib.helpers_import import insert_crash_change_template as insert_change_template
from lib.sshkeytempdir import SshKeyTempDir, write_key_to_file
from lib.testing import mess_with_incoming_records_to_ensure_updates

DEPLOYMENT_ENVIRONMENT = os.environ.get(
    "ENVIRONMENT", "development"
)  # our current environment from ['production', 'development']
ONEPASSWORD_CONNECT_TOKEN = os.getenv("OP_API_TOKEN")  # our secret to get secrets 🤐
ONEPASSWORD_CONNECT_HOST = os.getenv("OP_CONNECT")  # where we get our secrets
VAULT_ID = os.getenv("OP_VAULT_ID")


def main():
    secrets = get_secrets()

    global ZIP_PASSWORD

    global AWS_ACCESS_KEY_ID
    global AWS_SECRET_ACCESS_KEY

    global DB_USER
    global DB_PASS
    global DB_NAME
    global DB_SSL_REQUIREMENT

    global DB_BASTION_HOST_SSH_USERNAME
    global DB_BASTION_HOST_SSH_PRIVATE_KEY
    global DB_BASTION_HOST
    global DB_RDS_HOST

    global GRAPHQL_ENDPOINT
    global GRAPHQL_ENDPOINT_KEY

    global S3_EXTRACT_BUCKET

    ZIP_PASSWORD = secrets["archive_extract_password"]

    AWS_ACCESS_KEY_ID = secrets["aws_access_key"]
    AWS_SECRET_ACCESS_KEY = secrets["aws_secret_key"]

    DB_USER = secrets["database_username"]
    DB_PASS = secrets["database_password"]
    DB_NAME = secrets["database_name"]
    DB_SSL_REQUIREMENT = secrets["database_ssl_policy"]

    DB_BASTION_HOST_SSH_USERNAME = secrets["bastion_ssh_username"]
    DB_BASTION_HOST_SSH_PRIVATE_KEY = secrets["bastion_ssh_private_key"]
    DB_BASTION_HOST = secrets["bastion_host"]
    DB_RDS_HOST = secrets["database_host"]

    GRAPHQL_ENDPOINT = secrets["graphql_endpoint"]
    GRAPHQL_ENDPOINT_KEY = secrets["graphql_endpoint_key"]

    S3_EXTRACT_BUCKET = secrets["s3_extract_bucket"]

    local_mode = False
    if bool(glob.glob("/app/development_extracts/*.zip")):
        local_mode = True

    zip_location = None
    if not local_mode:  # Production
        zip_location = download_s3_archive()
    else:  # Development. Put a zip in the development_extracts directory to use it.
        zip_location = specify_extract_location()

    if not zip_location:
        return

    extracted_archives = unzip_archives(zip_location)
    for archive_id, archive, filename_in_s3 in extracted_archives:
        logical_groups_of_csvs = group_csvs_into_logical_groups(archive, dry_run=False)
        for logical_group in logical_groups_of_csvs:
            desired_schema_name = create_import_schema_name(logical_group)
            schema_name = create_target_import_schema(desired_schema_name)
            pgloader_command_files = pgloader_csvs_into_database(schema_name)
            trimmed_token = remove_trailing_carriage_returns(pgloader_command_files)
            typed_token = align_db_typing(trimmed_token)
            align_records_token = align_records(typed_token)
            clean_up_import_schema(align_records_token)
        mark_extract_as_imported(archive_id)
        if not local_mode:
            move_extract_into_processed(filename_in_s3)


def move_extract_into_processed(extract):
    # Define the source and destination paths
    source = {
        "Bucket": S3_EXTRACT_BUCKET,
        "Key": f"{DEPLOYMENT_ENVIRONMENT}/inbox/{extract}",
    }
    destination = os.path.join(f"{DEPLOYMENT_ENVIRONMENT}/processed/", extract)

    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )

    s3 = session.client("s3")
    bucket = S3_EXTRACT_BUCKET

    # Copy the file from the source to the destination
    s3.copy(source, bucket, destination)

    # Delete the file from the source
    s3.delete_object(Bucket=bucket, Key=source["Key"])

    print(f"Moving {extract} into processed")


def mark_extract_as_imported(id):
    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        cursor = pg.cursor()
        cursor.execute(
            """
            UPDATE cris_import_log
            SET completed_at = %s
            WHERE id = %s
            """,
            (datetime.datetime.utcnow(), id),
        )

        pg.commit()
        pg.close()


def get_secrets():
    REQUIRED_SECRETS = {
        "sftp_endpoint_private_key": {
            "opitem": "SFTP Endpoint Key",
            "opfield": ".private key",
            "opvault": VAULT_ID,
        },
        "archive_extract_password": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": "Common.CRIS Archive Extract Password",
            "opvault": VAULT_ID,
        },
        "bastion_host": {
            "opitem": "RDS Bastion Host",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Host",
            "opvault": VAULT_ID,
        },
        "bastion_ssh_username": {
            "opitem": "RDS Bastion Host",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.ssh Username",
            "opvault": VAULT_ID,
        },
        "database_host": {
            "opitem": "Vision Zero Database",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Host",
            "opvault": VAULT_ID,
        },
        "database_username": {
            "opitem": "Vision Zero Database",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Username",
            "opvault": VAULT_ID,
        },
        "database_password": {
            "opitem": "Vision Zero Database",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Password",
            "opvault": VAULT_ID,
        },
        "database_name": {
            "opitem": "Vision Zero Database",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Name",
            "opvault": VAULT_ID,
        },
        "database_ssl_policy": {
            "opitem": "Vision Zero Database",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database SSL Policy",
            "opvault": VAULT_ID,
        },
        "aws_access_key": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.AWS Access key",
            "opvault": VAULT_ID,
        },
        "aws_secret_key": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.AWS Secret key",
            "opvault": VAULT_ID,
        },
        "graphql_endpoint": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.GraphQL Endpoint",
            "opvault": VAULT_ID,
        },
        "graphql_endpoint_key": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.GraphQL Endpoint key",
            "opvault": VAULT_ID,
        },
        "sftp_endpoint_private_key": {
            "opitem": "SFTP Endpoint Key",
            "opfield": ".private key",
            "opvault": VAULT_ID,
        },
        "bastion_ssh_private_key": {
            "opitem": "RDS Bastion Key",
            "opfield": ".private key",
            "opvault": VAULT_ID,
        },
        "s3_extract_bucket": {
            "opitem": "Vision Zero CRIS Import",
            "opfield": f"{DEPLOYMENT_ENVIRONMENT}.S3 Extract Bucket",
            "opvault": VAULT_ID,
        },
    }

    # instantiate a 1Password client
    client: Client = new_client(ONEPASSWORD_CONNECT_HOST, ONEPASSWORD_CONNECT_TOKEN)
    # get the requested secrets from 1Password
    return onepasswordconnectsdk.load_dict(client, REQUIRED_SECRETS)


def specify_extract_location():
    zip_files = glob.glob("/app/development_extracts/*.zip")
    if not zip_files:
        return False

    zip_tmpdir = tempfile.mkdtemp()

    for file_to_copy in zip_files:
        filename_no_path = os.path.basename(file_to_copy)
        shutil.copy(file_to_copy, zip_tmpdir)

    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )
        cursor = pg.cursor()
        cursor.execute(
            """
                INSERT INTO cris_import_log (object_path, object_name)
                VALUES (%s, %s)
                """,
            ("local/development", filename_no_path),
        )
        pg.commit()
        pg.close()

    return zip_tmpdir


def download_s3_archive():
    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )

    s3 = session.client("s3")
    bucket = S3_EXTRACT_BUCKET

    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        uploads_prefix = f"{DEPLOYMENT_ENVIRONMENT}/inbox/"
        # Get list of all objects in the bucket with the specified prefix
        objects = s3.list_objects(Bucket=bucket, Prefix=uploads_prefix)

        cursor = pg.cursor()

        extracts_to_process = []

        for obj in objects["Contents"]:
            full_object_path = obj["Key"]
            object_name = os.path.basename(full_object_path)

            # Skip the "folder" object
            if full_object_path == uploads_prefix:
                continue

            # Extract the S3 prefix from the full object path
            object_path = os.path.dirname(full_object_path)

            extracts_to_process.append((object_path, object_name))

            cursor.execute(
                """
                INSERT INTO cris_import_log (object_path, object_name)
                VALUES (%s, %s)
                """,
                (object_path, object_name),
            )

        # Commit the changes and close the connection
        pg.commit()
        pg.close()

        # Check if there are no new files to process
        if len(extracts_to_process) == 0:
            raise Exception("No new files to process")

        # Create a new temporary directory
        directory_of_extracts = tempfile.mkdtemp()

        for extract in extracts_to_process:
            full_s3_path = os.path.join(extract[0], extract[1])
            local_extract_path = os.path.join(directory_of_extracts, extract[1])
            s3.download_file(bucket, full_s3_path, local_extract_path)

            # # Check if the file has been downloaded
            if not os.path.exists(local_extract_path):
                raise Exception(f"File {local_extract_path} was not downloaded")

            # # Check if the file is a zip file
            if "Zip" not in magic.from_file(local_extract_path):
                raise Exception(f"File {local_extract_path} is not a valid zip file")

        return directory_of_extracts


def unzip_archives(archives_directory):
    """
    Unzips (and decrypts) archives received from CRIS

    Arguments: A path to a directory containing archives as a string

    Returns: A list of strings, each denoting a path to a folder
    containing an archive's contents
    """

    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        extracted_csv_directories = []
        for filename in os.listdir(archives_directory):
            print("About to unzip: " + filename + "with the command ...")
            extract_tmpdir = tempfile.mkdtemp()
            unzip_command = f'7za -y -p{ZIP_PASSWORD} -o"{extract_tmpdir}" x "{archives_directory}/{filename}"'
            print(unzip_command)
            os.system(unzip_command)

            cursor = pg.cursor()
            cursor.execute(
                "select id from cris_import_log where object_name = %s order by created_at desc limit 1",
                (filename,),
            )
            id = cursor.fetchone()[0]
            extracted_csv_directories.append((id, extract_tmpdir, filename))

        pg.commit()
        pg.close()

        return extracted_csv_directories


def cleanup_temporary_directories(
    zip_location, pgloader_command_files, extracted_archives
):
    """
    Remove directories that have accumulated during the flow's execution

    Arguments:
        zip_location: A string containing a path to a temporary directory
        extracted_archives: A list of strings each containing a path to a temporary directory
        unit_import_tmpdirs: A list of strings each containing a path to a temporary directory
        person_import_tmpdirs: A list of strings each containing a path to a temporary directory
        primaryperson_import_tmpdirs: A list of strings each containing a path to a temporary directory
        charges_import_tmpdirs: A list of strings each containing a path to a temporary directory

    Returns: None
    """

    shutil.rmtree(zip_location)

    print(pgloader_command_files)
    for directory in pgloader_command_files:
        shutil.rmtree(directory)

    for directory in extracted_archives:
        shutil.rmtree(directory)

    return None


def pgloader_csvs_into_database(map_state):
    # Walk the directory and find all the CSV files
    pgloader_command_files_tmpdir = tempfile.mkdtemp()
    for root, dirs, files in os.walk(map_state["working_directory"]):
        for filename in files:
            if filename.endswith(".csv") and filename.startswith(
                map_state["csv_prefix"]
            ):
                # Extract the table name from the filename. They are named `crash`, `unit`, `person`, `primaryperson`, & `charges`.
                table = re.search("extract_[\d_]+(.*)_[\d].*\.csv", filename).group(1)

                headers_line_with_newline = None

                with open(map_state["working_directory"] + "/" + filename, "r") as file:
                    headers_line_with_newline = file.readline()
                headers_line = headers_line_with_newline.strip()

                headers = headers_line.split(",")
                command_file = pgloader_command_files_tmpdir + "/" + table + ".load"
                print(f"Command file: {command_file}")

                with SshKeyTempDir() as key_directory:
                    write_key_to_file(
                        key_directory + "/id_ed25519",
                        DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n",
                    )
                    # we're going to get away with opening up this tunnel here for all pgloader commands
                    # because they get executed before this goes out of scope
                    ssh_tunnel = SSHTunnelForwarder(
                        (DB_BASTION_HOST),
                        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
                        ssh_private_key=f"{key_directory}/id_ed25519",
                        remote_bind_address=(DB_RDS_HOST, 5432),
                    )
                    ssh_tunnel.start()

                    # See https://github.com/dimitri/pgloader/issues/768#issuecomment-693390290
                    CONNECTION_STRING = f"postgresql://{DB_USER}:{DB_PASS}@localhost:{ssh_tunnel.local_bind_port}/{DB_NAME}?sslmode=allow"

                    with open(command_file, "w") as file:
                        file.write(
                            f"""
    LOAD CSV
        FROM '{map_state["working_directory"]}/{filename}' ({headers_line})
        INTO  {CONNECTION_STRING}&{map_state["import_schema"]}.{table} ({headers_line})
        WITH truncate,
            skip header = 1
        BEFORE LOAD DO 
        $$ drop table if exists {map_state["import_schema"]}.{table}; $$,
        $$ create table {map_state["import_schema"]}.{table} (\n"""
                        )
                        fields = []
                        for field in headers:
                            fields.append(f"       {field} character varying")
                        file.write(",\n".join(fields))
                        file.write(
                            f"""
        );
    $$;\n"""
                        )
                    cmd = f"pgloader {command_file}"
                    if os.system(cmd) != 0:
                        raise Exception("pgloader did not execute successfully")

    return map_state


def remove_trailing_carriage_returns(map_state):
    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        columns = util.get_input_tables_and_columns(pg, map_state["import_schema"])
        for column in columns:
            util.trim_trailing_carriage_returns(pg, map_state["import_schema"], column)

    return map_state


def align_db_typing(map_state):
    """
    This function compares the target table in the VZDB with the corollary table in the import schema. For each column pair,
    the type of the VZDB table's column is applied to the import table. This acts as a strong typing check for all input data,
    and will raise an exception if CRIS begins feeding the system data it's not ready to parse and handle.

    Arguments:
        data_loaded_token: Boolean value received from the previously ran task which imported the CSV files into the database.

    Returns: Boolean representing the completion of the import table type alignment
    """

    # fmt: off
    # Note about the above comment. It's used to disable black linting. For this particular task, 
    # I believe it's more readable to not have it wrap long lists of function arguments. 

    with SshKeyTempDir() as key_directory:
        write_key_to_file(key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n") 
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432)
            )
        ssh_tunnel.start()   

        pg = psycopg2.connect(
            host='localhost', 
            port=ssh_tunnel.local_bind_port,
            user=DB_USER, 
            password=DB_PASS, 
            dbname=DB_NAME, 
            sslmode=DB_SSL_REQUIREMENT, 
            sslrootcert="/root/rds-combined-ca-bundle.pem"
            )

        # query list of the tables which were created by the pgloader import process
        imported_tables = util.get_imported_tables(pg, map_state["import_schema"])

        # pull our map which connects the names of imported tables to the target tables in VZDB
        table_mappings = mappings.get_table_map()

        # iterate over table list to make sure we only are operating on the tables we've designated:
        # crash, unit, person, & primaryperson
        for input_table in imported_tables:
            output_table = table_mappings.get(input_table["table_name"])
            if not output_table:
                continue

            # Safety check to make sure that all incoming data has each row complete with a value in each of the "key" columns. Key columns are
            # the columns which are used to uniquely identify the entity being represented by a record in the database. 
            util.enforce_complete_keying(pg, mappings.get_key_columns(), output_table, map_state["import_schema"], input_table)

            # collect the column types for the target table, to be applied to the imported table
            output_column_types = util.get_output_column_types(pg, output_table)

            # iterate on each column
            for column in output_column_types:
                # for that column, confirm that it is included in the incoming CRIS data
                input_column_type = util.get_input_column_type(pg, map_state["import_schema"], input_table, column)

                # skip columns which do not appear in the import data, such as the columns we have added ourselves to the VZDB
                if not input_column_type:
                    continue

                # form an ALTER statement to apply the type to the imported table's column
                alter_statement = util.form_alter_statement_to_apply_column_typing(map_state["import_schema"], input_table, column)
                print(f"Aligning types for {map_state['import_schema']}.{input_table['table_name']}.{column['column_name']}.")

                # and execute the statement
                cursor = pg.cursor()
                cursor.execute(alter_statement)
                pg.commit()

    # fmt: on
    return map_state


def align_records(map_state):
    """
    This function begins by preparing a number of list and string variables containing SQL fragments.
    These fragments are used to create queries which inspect the data differences between a pair of records.
    How the records differ, if at all, is used to create either an UPDATE or INSERT statement that keeps the VZDB
    up to date, including via backfill, from CRIS data.

    Additionally, this function demonstrates the ability to query a list of fields which are different for reporting
    and logging purposes.

    Arguments:
        typed_token: Boolean value received from task which aligned data types.

    Returns: Boolean representing the completion of the import / update
    """

    dry_run = map_state["dry_run"]

    # fmt: off
    
    with SshKeyTempDir() as key_directory:
        write_key_to_file(key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n") 
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432)
            )
        ssh_tunnel.start()   

        pg = psycopg2.connect(
            host='localhost', 
            port=ssh_tunnel.local_bind_port,
            user=DB_USER, 
            password=DB_PASS, 
            dbname=DB_NAME, 
            sslmode=DB_SSL_REQUIREMENT, 
            sslrootcert="/root/rds-combined-ca-bundle.pem"
            )

        print("Finding updated records")

        output_map = mappings.get_table_map()
        table_keys = mappings.get_key_columns()

        for table in output_map.keys():

            # Query the list of columns in the target table
            target_columns = util.get_target_columns(pg, output_map, table)

            # Get the list of columns which are designated to to be protected from updates
            no_override_columns = mappings.no_override_columns()[output_map[table]]

            # Load up the list of imported records to iterate over. 
            imported_records = util.load_input_data_for_keying(pg, map_state["import_schema"], table)

            # Get columns used to uniquely identify a record
            key_columns = mappings.get_key_columns()[output_map[table]]

            # Build SQL fragment used as a JOIN ON clause to link input and output tables
            linkage_clauses, linkage_sql = util.get_linkage_constructions(key_columns, output_map, table, map_state["import_schema"])

            # Build list of columns available for import by inspecting the input table
            input_column_names = util.get_input_column_names(pg, map_state["import_schema"], table, target_columns)

            # iterate over each imported record and determine correct action
            should_skip_update = False

            for source in imported_records:
                # Check unique key columns to make sure they all have a value
                for key_column in key_columns:
                    key_column_value = source[key_column]
                    if key_column_value is None:
                        print("\nSkipping because unique key column is missing")    
                        print(f"Table: {table}")
                        print(f"Missing key column: {key_column}")
                        should_skip_update = True

                # If we are missing a column that uniquely identifies the record, we should skip the update
                if should_skip_update:
                    for key_column in key_columns:
                        print(f"{key_column}: {source[key_column]}")
                    continue

                # generate some record specific SQL fragments to identify the record in larger queries
                record_key_sql, import_key_sql = util.get_key_clauses(table_keys, output_map, table, source, map_state["import_schema"])

                # To decide to UPDATE, we need to find a matching target record in the output table.
                # This function returns that record as a token of existence or false if none is available
                if util.fetch_target_record(pg, output_map, table, record_key_sql):
                    
                    # Cause the CR3s to be re-downloaded next time that ETL is run
                    util.invalidate_cr3(pg, source["crash_id"])

                    # Build 2 sets of 3 arrays of SQL fragments, one element per column which can be `join`ed together in subsequent queries.
                    column_assignments, column_comparisons, column_aggregators, important_column_assignments, important_column_comparisons, important_column_aggregators = util.get_column_operators(target_columns, no_override_columns, source, table, output_map, map_state["import_schema"])

                    # Check if the proposed update would result in a non-op, such as if there are no changes between the import and
                    # target record. If this is the case, continue to the next record. There's no changes needed in this case.
                    if util.check_if_update_is_a_non_op(pg, column_comparisons, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"]):
                        #print(f"Skipping update for {output_map[table]} {record_key_sql}")
                        continue

                    # For future reporting and debugging purposes: Use SQL to query a list of 
                    # column names which have differing values between the import and target records.
                    # Return these column names as an array and display them in the output.
                    changed_columns = util.get_changed_columns(pg, column_aggregators, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"])
                    
                    # Do the same thing, but this time using the SQL clauses formed from "important" columns.
                    important_changed_columns = util.get_changed_columns(pg, important_column_aggregators, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"])

                    if len(important_changed_columns['changed_columns']) > 0:
                        # This execution branch leads to the conflict resolution system in VZ

                        if util.is_change_existing(pg, table, source["crash_id"]):
                            continue

                        print("Important Changed column count: " + str(len(important_changed_columns['changed_columns'])))
                        print("Important Changed Columns:" + str(important_changed_columns["changed_columns"]))

                        print("Changed column count: " + str(len(changed_columns['changed_columns'])))
                        print("Changed Columns:" + str(changed_columns["changed_columns"]))
                        
                        # build an comma delimited list of changed columns
                        all_changed_columns = ", ".join(important_changed_columns["changed_columns"] + changed_columns["changed_columns"])

                        # insert_change_template() is used with minimal changes from previous version of the ETL to better ensure conflict system compatibility
                        mutation = insert_change_template(new_record_dict=source, differences=all_changed_columns, crash_id=str(source["crash_id"]))
                        if not dry_run:
                            print("Making a mutation for " + str(source["crash_id"]))
                            graphql.make_hasura_request(query=mutation, endpoint=GRAPHQL_ENDPOINT, admin_secret=GRAPHQL_ENDPOINT_KEY)
                    else:
                        # This execution branch leads to forming an update statement and executing it
                        if len(changed_columns["changed_columns"]) == 0:
                            print(update_statement)
                            raise "No changed columns? Why are we forming an update? This is a bug."

                        # Display the before and after values of the columns which are subject to update
                        util.show_changed_values(pg, changed_columns, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"])

                        # Using all the information we've gathered, form a single SQL update statement to update the target record.
                        update_statement = util.form_update_statement(output_map, table, column_assignments, map_state["import_schema"], record_key_sql, linkage_sql, changed_columns)
                        print(f"Executing update in {output_map[table]} for where " + record_key_sql)

                        # Execute the update statement
                        util.try_statement(pg, output_map, table, record_key_sql, update_statement, dry_run)


                # target does not exist, we're going to insert
                else:
                    # An insert is always just an vanilla insert, as there is not a pair of records to compare.
                    # Produce the SQL which creates a new VZDB record from a query of the imported data
                    insert_statement = util.form_insert_statement(output_map, table, input_column_names, import_key_sql, map_state["import_schema"])
                    print(f"Executing insert in {output_map[table]} for where " + record_key_sql)

                    # Execute the insert statement
                    util.try_statement(pg, output_map, table, record_key_sql, insert_statement, dry_run)

    # fmt: on
    return map_state


def group_csvs_into_logical_groups(extracted_archives, dry_run):
    files = os.listdir(str(extracted_archives))
    logical_groups = []
    for file in files:
        if file.endswith(".xml") or file == "crashReports":
            continue
        match = re.search("^extract_(\d+_\d+)_", file)
        group_id = match.group(1)
        if group_id not in logical_groups:
            logical_groups.append(group_id)
    map_safe_state = []
    for group in logical_groups:
        map_safe_state.append(
            {
                "logical_group_id": group,
                "working_directory": str(extracted_archives),
                "csv_prefix": "extract_" + group + "_",
                "dry_run": dry_run,
            }
        )
    print(map_safe_state)
    return map_safe_state


def create_import_schema_name(mapped_state):
    print(mapped_state)
    schema = (
        "import_"
        + hashlib.md5(mapped_state["logical_group_id"].encode()).hexdigest()[:12]
    )
    mapped_state["import_schema"] = schema
    print("Schema name: ", mapped_state["import_schema"])
    return mapped_state


def create_target_import_schema(map_state):
    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        cursor = pg.cursor()

        # check if the schema exists by querying the pg_namespace system catalog
        cursor.execute(
            f"SELECT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = '{map_state['import_schema']}')"
        )

        schema_exists = cursor.fetchone()[0]

        # if the schema doesn't exist, create it using a try-except block to handle the case where it already exists
        if not schema_exists:
            try:
                cursor.execute(f"CREATE SCHEMA {map_state['import_schema']}")
                print("Schema created successfully")
            except psycopg2.Error as e:
                print(f"Error creating schema: {e}")
        else:
            print("Schema already exists")

        # commit the changes and close the cursor and connection
        pg.commit()
        cursor.close()
        pg.close()

    return map_state


def clean_up_import_schema(map_state):
    with SshKeyTempDir() as key_directory:
        write_key_to_file(
            key_directory + "/id_ed25519", DB_BASTION_HOST_SSH_PRIVATE_KEY + "\n"
        )
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            ssh_private_key=f"{key_directory}/id_ed25519",
            remote_bind_address=(DB_RDS_HOST, 5432),
        )
        ssh_tunnel.start()

        pg = psycopg2.connect(
            host="localhost",
            port=ssh_tunnel.local_bind_port,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME,
            sslmode=DB_SSL_REQUIREMENT,
            sslrootcert="/root/rds-combined-ca-bundle.pem",
        )

        cursor = pg.cursor()
        sql = f"DROP SCHEMA IF EXISTS {map_state['import_schema']} CASCADE "
        cursor.execute(sql)

        pg.commit()
        cursor.close()
        pg.close()

    return map_state


if __name__ == "__main__":
    main()
