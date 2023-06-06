import sys
import os
import onepasswordconnectsdk
from airflow.decorators import dag, task
from onepasswordconnectsdk.client import Client, new_client
from datetime import datetime, timedelta
import logging

current_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, current_dir)

import lib.mappings as mappings
import lib.sql as util
import lib.graphql as graphql
from lib.helpers_import import insert_crash_change_template as insert_change_template

import re
import tempfile
import shutil
import psycopg2
import psycopg2.extras
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import sysrsync
import hashlib
from sshtunnel import SSHTunnelForwarder
import subprocess

DEPLOYMENT_ENVIRONMENT = os.environ.get("ENVIRONMENT", 'development')   # our current environment from ['production', 'development']
ONEPASSWORD_CONNECT_TOKEN = os.getenv("OP_API_TOKEN")                   # our secret to get secrets 🤐
ONEPASSWORD_CONNECT_HOST = os.getenv("OP_CONNECT")                      # where we get our secrets
VAULT_ID = os.getenv("OP_VAULT_ID")

# these temp directories are used to store ssh keys, because they will
# automatically clean themselves up when they go out of scope.
class SshKeyTempDir:
    def __init__(self):
        self.path = None

    def __enter__(self):
        self.path = tempfile.mkdtemp(dir='/tmp')
        return self.path

    def __exit__(self, exc_type, exc_val, exc_tb):
        shutil.rmtree(self.path)

def write_key_to_file(path, content):
    # Open the file with write permissions and create it if it doesn't exist
    fd = os.open(path, os.O_WRONLY | os.O_CREAT, 0o600)

    # Write the content to the file
    os.write(fd, content.encode())

    # Close the file
    os.close(fd)

@dag(
    dag_id="cris-import",
    description="Daily operation to download the latest CRIS data and import it into the database",
    schedule="0 7 * * *",
    start_date=datetime(2023, 1, 1), # these should be static
    catchup=False,
    concurrency=1,
    max_active_runs=1,
    tags=["vision-zero", "cris", "import"],
)
def cris_import():

    @task()
    def get_secrets():
        REQUIRED_SECRETS = {
            "SFTP_endpoint": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"Common.SFTP Endpoint",
                "opvault": VAULT_ID,
                },
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
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Bastion",
                "opvault": VAULT_ID,
                },
            "bastion_ssh_username": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Bastion ssh Username",
                "opvault": VAULT_ID,
                },
            "database_host": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Host",
                "opvault": VAULT_ID,
                },
            "database_username": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Username",
                "opvault": VAULT_ID,
                },
            "database_password": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Password",
                "opvault": VAULT_ID,
                },
            "database_name": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database Name",
                "opvault": VAULT_ID,
                },
            "database_ssl_policy": {
                "opitem": "Vision Zero CRIS Import",
                "opfield": f"{DEPLOYMENT_ENVIRONMENT}.Database SSL Policy",
                "opvault": VAULT_ID,
                },
        }

        # instantiate a 1Password client
        client: Client = new_client(ONEPASSWORD_CONNECT_HOST, ONEPASSWORD_CONNECT_TOKEN)
        # get the requested secrets from 1Password
        SECRETS = onepasswordconnectsdk.load_dict(client, REQUIRED_SECRETS)

        logger = logging.getLogger(__name__)
        logger.info("Secrets: " + str(SECRETS))

        return SECRETS

    @task()
    def download_archives(SECRETS):
        """
        Connect to the SFTP endpoint which receives archives from CRIS and
        download them into a temporary directory.

        Returns path of temporary directory as a string
        """

        logger = logging.getLogger(__name__)

        with SshKeyTempDir() as key_directory:
            logger.info("Key Directory: " + key_directory)
            write_key_to_file(key_directory + "/id_ed25519", SECRETS["sftp_endpoint_private_key"] + "\n") 

            # logger = prefect.context.get("logger")
            zip_tmpdir = tempfile.mkdtemp()
            logger.info("Zip Directory: " + zip_tmpdir)

            rsync = sysrsync.run(
                verbose=True,
                options=["-a"],
                source_ssh=SECRETS["SFTP_endpoint"],
                source="/home/txdot/*zip",
                sync_source_contents=False,
                destination=zip_tmpdir,
                private_key=key_directory + "/id_ed25519",
                strict_host_key_checking=False,
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

    @task()
    def unzip_archives(SECRETS, archives_directory):
        """
        Unzips (and decrypts) archives received from CRIS

        Arguments: A path to a directory containing archives as a string

        Returns: A list of strings, each denoting a path to a folder
        containing an archive's contents
        """

        logger = logging.getLogger(__name__)

        extracted_csv_directories = []
        for filename in os.listdir(archives_directory):
            logger.info("About to unzip: " + filename + "with the command ...")
            extract_tmpdir = tempfile.mkdtemp()
            unzip_command = f'7za -y -p{SECRETS["archive_extract_password"]} -o"{extract_tmpdir}" x "{archives_directory}/{filename}"'
            logger.info(unzip_command)
            os.system(unzip_command)
            extracted_csv_directories.append(extract_tmpdir)
        logger.info("Here are the extracted CSV directories: " + str(extracted_csv_directories))
        return extracted_csv_directories

    @task()
    def group_csvs_into_logical_groups(extracted_archives_list, dry_run, secrets):

        logger = logging.getLogger(__name__)

        # ! We now have Airflow's more robust map/reduce functionality, so we can .expand() on the result
        # ! from an already expanded task. https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html
        extracted_archives = extracted_archives_list[0]
        logger.info("Extracted Archive Location: " + str(extracted_archives))

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
                "secrets": secrets,
            })
        logger.info("Map Safe State: " + str(map_safe_state))
        return map_safe_state

    @task(max_active_tis_per_dag=1)
    def create_import_schema_name(map_state):
        import random

        logger = logging.getLogger(__name__)

        print(map_state)
        # ! FIXME take out this random string!!
        schema = 'import_' + hashlib.md5(map_state["logical_group_id"].encode() + random.randint(0,10000).to_bytes(2,'big')).hexdigest()[:12]
        map_state["import_schema"] = schema
        logger.info("Schema name: " + map_state["import_schema"])
        return map_state

    @task(max_active_tis_per_dag=1)
    def create_target_import_schema(map_state):

        DB_BASTION_HOST = map_state["secrets"]["bastion_host"]
        DB_BASTION_HOST_SSH_USERNAME = map_state["secrets"]["bastion_ssh_username"]
        DB_RDS_HOST = map_state["secrets"]["database_host"]
        DB_USER = map_state["secrets"]["database_username"]
        DB_PASS = map_state["secrets"]["database_password"]
        DB_NAME = map_state["secrets"]["database_name"]
        DB_SSL_REQUIREMENT = map_state["secrets"]["database_ssl_policy"]

        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            #ssh_private_key= '/root/.ssh/id_rsa',
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

        pg.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

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


    @task(
        max_active_tis_per_dag=1,
        #name="pgloader CSV into DB", 
        #max_retries=2, 
        #retry_delay=datetime.timedelta(minutes=1), 
        #state_handlers=[handler],
        )
    def pgloader_csvs_into_database(map_state):

        logger = logging.getLogger(__name__)  
        
        DB_BASTION_HOST = map_state["secrets"]["bastion_host"]
        DB_BASTION_HOST_SSH_USERNAME = map_state["secrets"]["bastion_ssh_username"]
        DB_RDS_HOST = map_state["secrets"]["database_host"]
        DB_USER = map_state["secrets"]["database_username"]
        DB_PASS = map_state["secrets"]["database_password"]
        DB_NAME = map_state["secrets"]["database_name"]
        DB_SSL_REQUIREMENT = map_state["secrets"]["database_ssl_policy"]


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

                    # we're going to get away with opening up this tunnel here for all pgloader commands
                    # because they get executed before this goes out of scope
                    ssh_tunnel = SSHTunnelForwarder(
                        (DB_BASTION_HOST),
                        ssh_username=DB_BASTION_HOST_SSH_USERNAME,
                        #ssh_private_key= '/root/.ssh/id_rsa',
                        remote_bind_address=(DB_RDS_HOST, 5432)
                        )
                    ssh_tunnel.start()  

                    # See https://github.com/dimitri/pgloader/issues/768#issuecomment-693390290
                    CONNECTION_STRING = f'postgresql://{DB_USER}:{DB_PASS}@localhost:{ssh_tunnel.local_bind_port}/{DB_NAME}?sslmode={DB_SSL_REQUIREMENT}'
                    logger.info(f'Connection string: {CONNECTION_STRING}')




                    with open(command_file, 'w') as file:
                        command_file_contents = f"""
    LOAD CSV
        FROM '{map_state["working_directory"]}/{filename}' ({headers_line})
        INTO  {CONNECTION_STRING}&{map_state["import_schema"]}.{table} ({headers_line})
        WITH truncate,
            skip header = 1
        BEFORE LOAD DO 
        $$ drop table if exists {map_state["import_schema"]}.{table}; $$,
        $$ create table {map_state["import_schema"]}.{table} (\n"""
                        fields = []
                        for field in headers:
                            fields.append(f'       {field} character varying') 
                        command_file_contents = command_file_contents + ',\n'.join(fields)
                        command_file_contents = command_file_contents + f"""
        );
    $$;\n"""
                        file.write(command_file_contents)
                        logger.info(f'Command file contents: {command_file_contents}')
                    cmd = f'pgloader {command_file}'
                    logger.info("pgloader command: " + cmd)
                    #if os.system(cmd) != 0:
                        #raise Exception("pgloader did not execute successfully")
                    try:
                        result = subprocess.run(["pgloader", command_file], check=True, text=True, capture_output=True)
                        logger.info(result.stdout)
                        #print('Output:', result.stdout)
                    except subprocess.CalledProcessError as e:
                        logger.info('The external program had an error:' + str(e))
 

        return map_state 

    @task(
        max_active_tis_per_dag=1,
        #name="Remove trailing carriage returns from imported data", 
        #state_handlers=[handler],
        )
    def remove_trailing_carriage_returns(map_state):

        logger = logging.getLogger(__name__) 

        DB_BASTION_HOST = map_state["secrets"]["bastion_host"]
        DB_BASTION_HOST_SSH_USERNAME = map_state["secrets"]["bastion_ssh_username"]
        DB_RDS_HOST = map_state["secrets"]["database_host"]
        DB_USER = map_state["secrets"]["database_username"]
        DB_PASS = map_state["secrets"]["database_password"]
        DB_NAME = map_state["secrets"]["database_name"]
        DB_SSL_REQUIREMENT = map_state["secrets"]["database_ssl_policy"]

        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            #ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

        pg.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

        columns = util.get_input_tables_and_columns(pg, map_state["import_schema"])
        for column in columns:
            logger.info("Trimming trailing carriage returns from column " + str(column))
            util.trim_trailing_carriage_returns(pg, map_state["import_schema"], column)

        #import time
        #time.sleep(60)

        return map_state


    @task(
        max_active_tis_per_dag=1,
        #name="Align DB Types", 
        #state_handlers=[handler],
        )
    def align_db_typing(map_state):

        """
        This function compares the target table in the VZDB with the corollary table in the import schema. For each column pair,
        the type of the VZDB table's column is applied to the import table. This acts as a strong typing check for all input data,
        and will raise an exception if CRIS begins feeding the system data it's not ready to parse and handle.

        Arguments:
            data_loaded_token: Boolean value received from the previously ran task which imported the CSV files into the database.

        Returns: Boolean representing the completion of the import table type alignment
        """
        logger = logging.getLogger(__name__) 

        logger.info("Map State: " + str(map_state))

        DB_BASTION_HOST = map_state["secrets"]["bastion_host"]
        DB_BASTION_HOST_SSH_USERNAME = map_state["secrets"]["bastion_ssh_username"]
        DB_RDS_HOST = map_state["secrets"]["database_host"]
        DB_USER = map_state["secrets"]["database_username"]
        DB_PASS = map_state["secrets"]["database_password"]
        DB_NAME = map_state["secrets"]["database_name"]
        DB_SSL_REQUIREMENT = map_state["secrets"]["database_ssl_policy"]

        # fmt: off
        # Note about the above comment. It's used to disable black linting. For this particular task, 
        # I believe it's more readable to not have it wrap long lists of function arguments. 

        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            #ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

        pg.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

        # query list of the tables which were created by the pgloader import process
        imported_tables = util.get_imported_tables(pg, map_state["import_schema"])
        logger.info("Imported Tables: " + str(imported_tables))

        # pull our map which connects the names of imported tables to the target tables in VZDB
        table_mappings = mappings.get_table_map()

        # iterate over table list to make sure we only are operating on the tables we've designated:
        # crash, unit, person, & primaryperson
        for input_table in imported_tables:
            logger.info("Input Table: " + str(input_table))
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

                logger.info(f"Aligning types for {map_state['import_schema']}.{input_table['table_name']}.{column['column_name']}.")
                logger.info(alter_statement)

                # and execute the statement
                cursor = pg.cursor()
                cursor.execute(alter_statement)
                pg.commit()
                cursor.close()

        # fmt: on
        return map_state 

    @task(
        max_active_tis_per_dag=1,
        #name="Insert / Update records in target schema", 
        #state_handlers=[handler],
        )
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

        DB_BASTION_HOST = map_state["secrets"]["bastion_host"]
        DB_BASTION_HOST_SSH_USERNAME = map_state["secrets"]["bastion_ssh_username"]
        DB_RDS_HOST = map_state["secrets"]["database_host"]
        DB_USER = map_state["secrets"]["database_username"]
        DB_PASS = map_state["secrets"]["database_password"]
        DB_NAME = map_state["secrets"]["database_name"]
        DB_SSL_REQUIREMENT = map_state["secrets"]["database_ssl_policy"]
        
        dry_run = map_state["dry_run"]

        logger = logging.getLogger(__name__) 

        # fmt: off
        
        ssh_tunnel = SSHTunnelForwarder(
            (DB_BASTION_HOST),
            ssh_username=DB_BASTION_HOST_SSH_USERNAME,
            #ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
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

        pg.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

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


    dry_run = False

    secrets = get_secrets()
    archive_location = download_archives(secrets)
    extracted_archives = unzip_archives(secrets, archive_location)
    logical_groups_of_csvs = group_csvs_into_logical_groups(extracted_archives, dry_run, secrets)
    desired_schema_name = create_import_schema_name.expand(map_state=logical_groups_of_csvs)
    schema_name = create_target_import_schema.expand(map_state=desired_schema_name)
    pgloader_command_files = pgloader_csvs_into_database.expand(map_state=schema_name)
    trimmed_token = remove_trailing_carriage_returns.expand(map_state=pgloader_command_files)
    typed_token = align_db_typing.expand(map_state=trimmed_token)
    align_records_token = align_records.expand(map_state=typed_token)

cris_import()