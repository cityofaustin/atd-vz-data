#!/usr/bin/python3

import sys
import os
import json
import shutil
import re
import time
import datetime
import tempfile
from subprocess import Popen, PIPE
import hashlib

import boto3
import sysrsync

import psycopg2
import psycopg2.extras

# Import various prefect packages and helper methods
import prefect
from prefect import task, Flow, Parameter
from prefect.backend import get_key_value
from prefect.engine.state import Failed, TriggerFailed, Retrying
from prefect.utilities.notifications import slack_notifier

import lib.mappings as mappings
import lib.sql as util
import lib.graphql as graphql
from lib.helpers_import import insert_crash_change_template as insert_change_template

from sshtunnel import SSHTunnelForwarder

SFTP_ENDPOINT = None
ZIP_PASSWORD = None
VZ_ETL_LOCATION = None

AWS_DEFAULT_REGION = None
AWS_ACCESS_KEY_ID = None
AWS_SECRET_ACCESS_KEY = None
AWS_CSV_ARCHIVE_BUCKET_NAME = None
AWS_CSV_ARCHIVE_PATH_PRODUCTION = None
AWS_CSV_ARCHIVE_PATH_STAGING = None

DB_HOST = None
DB_USER = None
DB_PASS = None
DB_NAME = None
DB_SSL_REQUIREMENT = None

DB_BASTION_HOST_SSH_USERNAME = None
DB_BASTION_HOST = None
DB_RDS_HOST = None

if True:
    kv_store = get_key_value("Vision Zero Development")
    kv_dictionary = json.loads(kv_store)
    SFTP_ENDPOINT = kv_dictionary["SFTP_ENDPOINT"]
    ZIP_PASSWORD = kv_dictionary["ZIP_PASSWORD"]
    VZ_ETL_LOCATION = kv_dictionary["VZ_ETL_LOCATION"]

    AWS_DEFAULT_REGION = kv_dictionary["AWS_DEFAULT_REGION"]
    AWS_ACCESS_KEY_ID = kv_dictionary["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = kv_dictionary["AWS_SECRET_ACCESS_KEY"]
    AWS_CSV_ARCHIVE_BUCKET_NAME = kv_dictionary["AWS_CSV_ARCHIVE_BUCKET_NAME"]
    AWS_CSV_ARCHIVE_PATH_PRODUCTION = kv_dictionary["AWS_CSV_ARCHIVE_PATH_PRODUCTION"]
    AWS_CSV_ARCHIVE_PATH_STAGING = kv_dictionary["AWS_CSV_ARCHIVE_PATH_STAGING"]

    DB_HOST = kv_dictionary["DB_HOST"]
    DB_USER = kv_dictionary["DB_USER"]
    DB_PASS = kv_dictionary["DB_PASS"]
    DB_NAME = kv_dictionary["DB_NAME"]
    DB_SSL_REQUIREMENT = kv_dictionary["DB_SSL_REQUIREMENT"]

    DB_BASTION_HOST_SSH_USERNAME = kv_dictionary["DB_BASTION_HOST_SSH_USERNAME"]
    DB_BASTION_HOST = kv_dictionary["DB_BASTION_HOST"]
    DB_RDS_HOST = kv_dictionary["DB_RDS_HOST"]
else:
    SFTP_ENDPOINT = os.getenv("SFTP_ENDPOINT")
    ZIP_PASSWORD = os.getenv("ZIP_PASSWORD")
    VZ_ETL_LOCATION = os.getenv("VZ_ETL_LOCATION")

    AWS_DEFAULT_REGION = os.getenv("AWS_DEFAULT_REGION")
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AWS_CSV_ARCHIVE_BUCKET_NAME = os.getenv("AWS_CSV_ARCHIVE_BUCKET_NAME")
    AWS_CSV_ARCHIVE_PATH_PRODUCTION = os.getenv("AWS_CSV_ARCHIVE_PATH_PRODUCTION")
    AWS_CSV_ARCHIVE_PATH_STAGING = os.getenv("AWS_CSV_ARCHIVE_PATH_STAGING")

    DB_HOST = os.getenv("DB_HOST")
    DB_USER = os.getenv("DB_USER")
    DB_PASS = os.getenv("DB_PASS")
    DB_NAME = os.getenv("DB_NAME")
    DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")

    DB_BASTION_HOST_SSH_USERNAME = os.getenv("DB_BASTION_HOST_SSH_USERNAME")
    DB_BASTION_HOST = os.getenv("DB_BASTION_HOST")
    DB_RDS_HOST = os.getenv("DB_RDS_HOST")

def specify_extract_location(file):
    zip_tmpdir = tempfile.mkdtemp()
    shutil.copy(file, zip_tmpdir)
    return zip_tmpdir


def download_extract_archives():
    """
    Connect to the SFTP endpoint which receives archives from CRIS and
    download them into a temporary directory.

    Returns path of temporary directory as a string
    """

    logger = prefect.context.get("logger")
    zip_tmpdir = tempfile.mkdtemp()
    rsync = sysrsync.run(
        verbose=True,
        options=["-a"],
        source_ssh=SFTP_ENDPOINT,
        source="/home/txdot/*zip",
        sync_source_contents=False,
        destination=zip_tmpdir,
    )
    logger.info("Rsync return code: " + str(rsync.returncode))
    # check for a OS level return code of anything non-zero, which
    # would indicate to us that the child proc we kicked off didn't
    # complete successfully.
    # see: https://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
    if rsync.returncode != 0:
        return False
    logger.info("Temp Directory: " + zip_tmpdir)
    return zip_tmpdir


def unzip_archives(archives_directory):
    """
    Unzips (and decrypts) archives received from CRIS

    Arguments: A path to a directory containing archives as a string

    Returns: A list of strings, each denoting a path to a folder
    containing an archive's contents
    """

    logger = prefect.context.get("logger")
    extracted_csv_directories = []
    for filename in os.listdir(archives_directory):
        logger.info("About to unzip: " + filename + "with the command ...")
        extract_tmpdir = tempfile.mkdtemp()
        unzip_command = f'7za -y -p{ZIP_PASSWORD} -o"{extract_tmpdir}" x "{archives_directory}/{filename}"'
        logger.info(unzip_command)
        os.system(unzip_command)
        extracted_csv_directories.append(extract_tmpdir)
    return extracted_csv_directories



def cleanup_temporary_directories(zip_location, pgloader_command_files, extracted_archives):
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

    logger = prefect.context.get("logger")

    shutil.rmtree(zip_location)

    print(pgloader_command_files)
    for directory in pgloader_command_files:
        shutil.rmtree(directory)

    for directory in extracted_archives:
        shutil.rmtree(directory)

    return None



def upload_csv_files_to_s3(extract_directory):
    """
    Upload CSV files which came from CRIS exports up to S3 for archival

    Arguments:
        extract_directory: String denoting the full path of a directory containing extracted CSV files

    Returns:
        extract_directory: String denoting the full path of a directory containing extracted CSV files
            NB: The in-and-out unchanged data in this function is more about serializing prefect tasks and less about inter-functional communication
    """
    logger = prefect.context.get("logger")

    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )
    s3 = session.resource("s3")

    # for extract_directory in extracts:
    for filename in os.listdir(extract_directory):
        logger.info("About to upload to s3: " + filename)
        destination_path = (
            AWS_CSV_ARCHIVE_PATH_STAGING
            + "/"
            + str(datetime.date.today())
            # AWS_CSV_ARCHIVE_PATH_PRODUCTION + "/" + str(datetime.date.today())
        )
        s3.Bucket(AWS_CSV_ARCHIVE_BUCKET_NAME).upload_file(
            extract_directory + "/" + filename,
            destination_path + "/" + filename,
        )
    return extract_directory



def remove_archives_from_sftp_endpoint(zip_location, map_state):
    """
    Delete the archives which have been processed from the SFTP endpoint

    Arguments:
        zip_location: Stringing containing path of a directory containing the zip files downloaded from SFTP endpoint

    Returns: None
    """

    logger = prefect.context.get("logger")
    logger.info(zip_location)
    for archive in os.listdir(zip_location):
        logger.info(archive)
        command = f"ssh {SFTP_ENDPOINT} rm -v /home/txdot/{archive}"
        logger.info(command)
        cmd = command.split()
        rm_result = Popen(cmd, stdout=PIPE, stderr=PIPE, stdin=PIPE).stdout.read()
        logger.info(rm_result)

    return None


def pgloader_csvs_into_database(map_state):
    # Walk the directory and find all the CSV files
    pgloader_command_files_tmpdir = tempfile.mkdtemp()
    for root, dirs, files in os.walk(map_state["working_directory"]):
        for filename in files:
            if filename.endswith(".csv") and filename.startswith(map_state["csv_prefix"]):
                # Extract the table name from the filename. They are named `crash`, `unit`, `person`, `primaryperson`, & `charges`.
                table = re.search("extract_[\d_]+(.*)_[\d].*\.csv", filename).group(1)

                headers_line_with_newline = None

                with open(map_state["working_directory"] + "/" + filename, "r") as file:
                    headers_line_with_newline = file.readline()
                headers_line = headers_line_with_newline.strip()

                headers = headers_line.split(',')
                command_file = pgloader_command_files_tmpdir + "/" + table + ".load"
                print(f'Command file: {command_file}')

                # we're going to get away with opening up this tunnel here for all pgloader commands
                # because they get executed before this goes out of scope
                ssh_tunnel = SSHTunnelForwarder(
                    (DB_BASTION_HOST),
                    ssh_username=DB_BASTION_HOST_SSH_USERNAME,
                    ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
                    remote_bind_address=(DB_RDS_HOST, 5432)
                    )
                ssh_tunnel.start()  

                # See https://github.com/dimitri/pgloader/issues/768#issuecomment-693390290
                CONNECTION_STRING = f'postgresql://{DB_USER}:{DB_PASS}@localhost:{ssh_tunnel.local_bind_port}/{DB_NAME}?sslmode=allow'

                with open(command_file, 'w') as file:
                    file.write(f"""
LOAD CSV
    FROM '{map_state["working_directory"]}/{filename}' ({headers_line})
    INTO  {CONNECTION_STRING}&{map_state["import_schema"]}.{table} ({headers_line})
    WITH truncate,
        skip header = 1
    BEFORE LOAD DO 
    $$ drop table if exists {map_state["import_schema"]}.{table}; $$,
    $$ create table {map_state["import_schema"]}.{table} (\n""")
                    fields = []
                    for field in headers:
                        fields.append(f'       {field} character varying') 
                    file.write(',\n'.join(fields))
                    file.write(f"""
    );
$$;\n""")
                cmd = f'pgloader {command_file}'
                if os.system(cmd) != 0:
                    raise Exception("pgloader did not execute successfully")

    return map_state 


def remove_trailing_carriage_returns(map_state):

    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

    logger = prefect.context.get("logger")

    # fmt: off
    
    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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
        for source in imported_records:

            # generate some record specific SQL fragments to identify the record in larger queries
            record_key_sql, import_key_sql = util.get_key_clauses(table_keys, output_map, table, source, map_state["import_schema"])

            # To decide to UPDATE, we need to find a matching target record in the output table.
            # This function returns that record as a token of existence or false if none is available
            if util.fetch_target_record(pg, output_map, table, record_key_sql):
                # Build 2 sets of 3 arrays of SQL fragments, one element per column which can be `join`ed together in subsequent queries.
                column_assignments, column_comparisons, column_aggregators, important_column_assignments, important_column_comparisons, important_column_aggregators = util.get_column_operators(target_columns, no_override_columns, source, table, output_map, map_state["import_schema"])

                # Check if the proposed update would result in a non-op, such as if there are no changes between the import and
                # target record. If this is the case, continue to the next record. There's no changes needed in this case.
                if util.check_if_update_is_a_non_op(pg, column_comparisons, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"]):
                    #logger.info(f"Skipping update for {output_map[table]} {record_key_sql}")
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
                    
                    try:
                        # this seemingly violates the principal of treating each record source equally, however, this is 
                        # really only a reflection that we create incomplete temporary records consisting only of a crash record
                        # and not holding place entities for units, persons, etc.
                        if table == "crash" and util.has_existing_temporary_record(pg, source["case_id"]):
                            print("\b🛎: " + str(source["crash_id"]) + " has existing temporary record")
                            time.sleep(5)
                            util.remove_existing_temporary_record(pg, source["case_id"])
                    except:
                        # Trap the case of a missing case_id key error in the RealDictRow object.
                        # A RealDictRow, returned by the psycopg2 cursor, is a dictionary-like object,
                        # but lacks has_key() and other methods.
                        print("Skipping checking on existing temporary record for " + str(source["crash_id"]))
                        pass
                    
                    # build an comma delimited list of changed columns
                    all_changed_columns = ", ".join(important_changed_columns["changed_columns"] + changed_columns["changed_columns"])

                    # insert_change_template() is used with minimal changes from previous version of the ETL to better ensure conflict system compatibility
                    mutation = insert_change_template(new_record_dict=source, differences=all_changed_columns, crash_id=str(source["crash_id"]))
                    if not dry_run:
                        print("Making a mutation for " + str(source["crash_id"]))
                        graphql.make_hasura_request(query=mutation)
                else:
                    # This execution branch leads to forming an update statement and executing it
                    
                    if len(changed_columns["changed_columns"]) == 0:
                        logger.info(update_statement)
                        raise "No changed columns? Why are we forming an update? This is a bug."

                    # Display the before and after values of the columns which are subject to update
                    util.show_changed_values(pg, changed_columns, output_map, table, linkage_clauses, record_key_sql, map_state["import_schema"])

                    # Using all the information we've gathered, form a single SQL update statement to update the target record.
                    update_statement = util.form_update_statement(output_map, table, column_assignments, map_state["import_schema"], record_key_sql, linkage_sql, changed_columns)
                    logger.info(f"Executing update in {output_map[table]} for where " + record_key_sql)

                    # Execute the update statement
                    util.try_statement(pg, output_map, table, record_key_sql, update_statement, dry_run)


            # target does not exist, we're going to insert
            else:
                # An insert is always just an vanilla insert, as there is not a pair of records to compare.
                # Produce the SQL which creates a new VZDB record from a query of the imported data
                insert_statement = util.form_insert_statement(output_map, table, input_column_names, import_key_sql, map_state["import_schema"])
                logger.info(f"Executing insert in {output_map[table]} for where " + record_key_sql)

                # Execute the insert statement
                util.try_statement(pg, output_map, table, record_key_sql, insert_statement, dry_run)

    # fmt: on
    return map_state


def group_csvs_into_logical_groups(extracted_archives, dry_run):
    files = os.listdir(str(extracted_archives))
    logical_groups = []
    for file in files:
        if file.endswith(".xml"):
            continue
        match = re.search("^extract_(\d+_\d+)_", file)
        group_id = match.group(1)
        if group_id not in logical_groups:
            logical_groups.append(group_id)
    print("logical groups: " + str(logical_groups))
    map_safe_state = []
    for group in logical_groups:
        map_safe_state.append({
            "logical_group_id": group,
            "working_directory": str(extracted_archives),
            "csv_prefix": "extract_" + group + "_",
            "dry_run": dry_run,
        })
    print(map_safe_state)
    return map_safe_state


def create_import_schema_name(mapped_state):
    print(mapped_state)
    schema = 'import_' + hashlib.md5(mapped_state["logical_group_id"].encode()).hexdigest()[:12]
    mapped_state["import_schema"] = schema
    print("Schema name: ", mapped_state["import_schema"])
    return mapped_state


def create_target_import_schema(map_state):
    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

    cursor = pg.cursor()
    
    # check if the schema exists by querying the pg_namespace system catalog
    cursor.execute(f"SELECT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = '{map_state['import_schema']}')")

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
    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

    cursor = pg.cursor()
    sql = f"DROP SCHEMA IF EXISTS {map_state['import_schema']} CASCADE "
    cursor.execute(sql)

    pg.commit()
    cursor.close()
    pg.close()

    return map_state

def main():
    pass
    #dry_run = Parameter("dry_run", default=True, required=True)

    # get a location on disk which contains the zips from the sftp endpoint
    #zip_location = download_extract_archives()

    # OR

    # zip_location = specify_extract_location(
    # "/root/cris_import/data/apr-19-dual-schema-export.zip",
    # "/root/cris_import/data/july-2022.zip",
    # "/root/cris_import/data/nov21-sep22.zip",
    # )

    # iterate over the zips in that location and unarchive them into
    # a list of temporary directories containing the files of each
    #extracted_archives = unzip_archives(zip_location) # this returns an array, but is not mapped on

    #logical_groups_of_csvs = group_csvs_into_logical_groups(extracted_archives[0], dry_run)

    #desired_schema_name = create_import_schema_name.map(logical_groups_of_csvs)

    #schema_name = create_target_import_schema.map(desired_schema_name)

    #pgloader_command_files = pgloader_csvs_into_database.map(schema_name)

    #trimmed_token = remove_trailing_carriage_returns.map(pgloader_command_files)

    #typed_token = align_db_typing.map(trimmed_token)

    #align_records_token = align_records.map(map_state=typed_token)

    #clean_up_import_schema = clean_up_import_schema.map(align_records_token)

    # remove archives from SFTP endpoint; note this isn't a map'd function, this is reduced
    #removal_token = remove_archives_from_sftp_endpoint(zip_location, clean_up_import_schema)

    # push up the CSVs to s3 for archival
    #uploaded_archives_csvs = upload_csv_files_to_s3(extracted_archives[0])

    # i'm punting on this. 👇 This is oddly difficult after the map() refactor.

    # the whole thing won't have state from ETL run to ETL run once we migrate from prefect 1,
    # so this tidy-up won't matter and will be handled by the docker service as it cleans up stale containers.

    # it also accumulates maybe .5 megs a day, no big deal for time on the scale of months

    #cleanup = cleanup_temporary_directories(
        #zip_location,
        #extracted_archives[0],
        #pgloader_command_files,
        #upstream_tasks=[align_records_token],
        #upstream_tasks=[align_records_token, removal_token],
        #)
