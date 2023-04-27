#!/usr/bin/env python

import csv
import json
import time
import re
import os
import psycopg2
import psycopg2.extras
#from dotenv import load_dotenv

#load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")


def get_pg_connection():
    """
    Returns a connection to the Postgres database
    """
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME,
        sslmode=DB_SSL_REQUIREMENT,
        sslrootcert="/root/rds-combined-ca-bundle.pem",
    )


def table_exists(conn, table_name):
    """
    Checks if a table exists in a PostgreSQL database.

    Args:
    conn (psycopg2.extensions.connection): A connection to the PostgreSQL database.
    table_name (str): The name of the table to check for existence.

    Returns:
    bool: True if the table exists, False otherwise.
    """
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_name = %s
                );
            """,
                (table_name,),
            )

            result = cur.fetchone()
            return result[0]

    except Exception as e:
        print(f"Error checking table existence: {e}")
        return False


def read_and_group_csv(file_path):
    grouped_data = {}

    with open(file_path, newline="") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=",", quotechar='"')

        # Skip the first row (header)
        next(csvreader)

        for row in csvreader:
            key = row[0]
            inner_dict = {"id": int(row[1]), "description": row[2]}

            if key not in grouped_data:
                grouped_data[key] = []

            grouped_data[key].append(inner_dict)

    return grouped_data

def escape_single_quotes(input_string):
    return input_string.replace("'", "''")


file_path = (
    "/home/frank/atd-vz-data/atd-toolbox/materials_from_ldm_conversion/lookup_data/"
    + "extract_2023_20230424123049_lookup_20230401_HAYSTRAVISWILLIAMSON.csv"
)
data = read_and_group_csv(file_path)

# Pretty-print the grouped data as JSON
# print(json.dumps(data, indent=4))


def new_table(name):
    return f"""
    create table public.atd_txdot__{name}_lkp (
        id serial primary key,
        {name}_id integer not null,
        {name}_desc varchar(255) not null
    );
    """


def execute_query(pg, query):
    # return
    cursor = pg.cursor()
    cursor.execute(query)
    pg.commit()

def main():
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    changes = []
    for table in data:
        # here are tables which are special cases
        # The states (as in United States) is non-uniform and does not need inspection.
        # The counties are equally fixed.
        if table in ["STATE_ID", "CNTY_ID"]:
            continue

        # here are tables which have a ton of changes, and i want to suppress from the report
        # these still need to be processed!
        is_core = True
        if table in [
            "VEH_MOD_ID",
            "CITY_ID",
            "AGENCY_ID",
            "INV_DA_ID",
            "VEH_MAKE_ID",
            "VEH_DAMAGE_DESCRIPTION_ID",
            "OTHR_FACTR_ID",
        ]:
            is_core = False

        if not is_core:
            # continue
            pass

        match = re.search(r"(^.*)_ID$", table)
        name_component = match.group(1).lower()

        print()
        print("👀Looking into table: ", name_component)

        table_name = "atd_txdot__" + name_component + "_lkp"
        exists = table_exists(pg, table_name)
        for record in data[table]:
            if not exists:
                print("💥 Missing table: ", table_name)
                changes.append(new_table(name_component))
                execute_query(pg, new_table(name_component))
                # insert = f"insert into public.{table_name} ({name_component}_id, {name_component}_desc) values ({str(record['id'])}, '{escape_single_quotes(record['description'])}');"
                # print(insert)
                # changes.append(insert)
                # execute_query(pg, insert)
            # print(name_component, record)
            sql = f"""
            select {name_component}_id as id, {name_component}_desc as description 
            from {table_name} where {name_component}_id = {str(record['id'])};
            """
            cursor.execute(sql)
            db_result = cursor.fetchone()
            if db_result:
                # We have a record on file with this ID
                if db_result["description"] == record["description"]:
                    # print(f"✅ Value \"{record['description']}\" with id {str(record['id'])} found in {table_name}")
                    pass
                else:
                    print(
                        f"❌ Id {str(record['id'])} found in {table_name} has a description mismatch:"
                    )
                    print("      CSV Value: ", record["description"])
                    print("       DB Value: ", db_result["description"])
                    print()
                    update = f"update public.{table_name} set {name_component}_desc = '{escape_single_quotes(record['description'])}' where {name_component}_id = {str(record['id'])};"
                    print(update)
                    changes.append(update)
                    execute_query(pg, update)
            else:
                # We do not have a record on file with this ID
                # print(f"Value \"{record['description']}\" with id {str(record['id'])} not found in {table_name}")
                print(f"❓ Id {str(record['id'])} not found in {table_name}")
                print("      CSV Value: ", record["description"])
                print()
                insert = f"insert into public.{table_name} ({name_component}_id, {name_component}_desc) values ({str(record['id'])}, '{escape_single_quotes(record['description'])}');"
                # print(insert)
                changes.append(insert)
                execute_query(pg, insert)

    print("\n🛠️ Here are the changes to be made:\n")
    print("\n".join(changes))

if __name__ == "__main__":
    main()
