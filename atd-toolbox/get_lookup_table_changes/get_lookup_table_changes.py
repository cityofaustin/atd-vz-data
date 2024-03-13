#!/usr/bin/env python

import csv
import json
import time
import re
import os
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv
import argparse

load_dotenv("env")

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


def get_db_lkp_tables(conn):
    """
    Gets a list of all the lookup tables we have in our database that have the CRIS lkp
    prefix/suffix pattern.

    Args:
    conn (psycopg2.extensions.connection): A connection to the PostgreSQL database.

    Returns:
    list: Containing the lookup table names.
    """
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name 
                FROM information_schema.tables
                WHERE table_name LIKE 'atd_txdot%lkp'
                    AND table_schema = 'public'
                    AND table_type = 'BASE TABLE';
            """,
            )

            result = [record[0] for record in cur.fetchall()]
            return result

    except Exception as e:
        print(f"Error fetching lookup table names: {e}")
        return False


def get_lkp_values(conn, table_name, name_component):
    """
    Returns a dict where each key is the lkp id and the value
    is the lkp desc.

    Args:
    conn (psycopg2.extensions.connection): A connection to the PostgreSQL database.

    Returns:
    dict: Containing the lookup id/desc pairs for the provided table.
    """
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"""
                SELECT {name_component}_id, {name_component}_desc
                FROM {table_name};
            """,
            )
            result = cur.fetchall()
            return dict(result)

    except Exception as e:
        print(f"Error fetching lookup dict of {table_name}: {e}")
        return False


def read_and_group_csv(file_path):
    """
    Returns a dict where each key is the lookup table name and the value
    is a dict of all the lookup ids/descs for that lookup table
    """
    grouped_data = {}

    with open(file_path, newline="") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=",", quotechar='"')

        # Skip the first row (header)
        next(csvreader)

        for row in csvreader:
            id_name = row[0]
            name = re.search(r"(^.*)_ID$", id_name)
            name_component = name.group(1).lower()
            table_name = "atd_txdot__" + name_component + "_lkp"

            if table_name not in grouped_data:
                grouped_data[table_name] = {}

            grouped_data[table_name][int(row[1])] = row[2]

    return grouped_data


def escape_single_quotes(input_string):
    return input_string.replace("'", "''")


def new_table(name):
    return f"""
    create table public.atd_txdot__{name}_lkp (
        id serial primary key,
        {name}_id integer not null,
        {name}_desc varchar(255) not null
    );
    """


def main(file_path):
    # Group the lkp extract into a dict of dicts
    extract_data = read_and_group_csv(file_path)

    # Pretty-print the grouped data as JSON
    # print(json.dumps(extract_data, indent=4))

    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # Get a list of the lkp tables we have in our db
    db_tables = get_db_lkp_tables(pg)
    # These are lkp tables we have in our db that aren't in the extract and are possibly cruft
    tables_to_delete = list(set(db_tables) - set(list(extract_data.keys())))

    changes = []
    down_changes = []

    for table in tables_to_delete:
        print("❓Lookup table ", table, " found in database and not in extract")
        print()
        drop_table = f"drop table public.{table};"
        changes.append(f"\n-- Dropping table {table}")
        changes.append(drop_table)

    for table in extract_data:
        # here are tables which are special cases
        # The states (as in United States) is non-uniform and does not need inspection.
        # The counties are equally fixed.
        if table in ["atd_txdot__state_lkp", "atd_txdot__cnty_lkp"]:
            continue
        name_component = table.removeprefix("atd_txdot__").removesuffix("_lkp")
        extract_table_dict = extract_data[table]

        print()
        print("👀Looking into table: ", table)

        if table not in db_tables:
            print("💥 Missing table: ", table)
            changes.append(f"\n-- Adding table {table}")
            changes.append(new_table(name_component))
            down_changes.append(f"\n-- Dropping table {table}")
            new_table_down = f"drop table if exists public.{table};"
            down_changes.append(new_table_down)
            for key in extract_table_dict:
                insert = f"insert into public.{table} ({name_component}_id, {name_component}_desc) values ({str(key)}, '{escape_single_quotes(extract_table_dict[key])}');"
                changes.append(insert)
                # Dont need down changes here because the down is just deleting the table
        else:
            # Get the values we have for this lkp table in our db as a dict of ids/descs
            our_table_dict = get_lkp_values(pg, table, name_component)
            # These variables just to help with formatting the comments printed to output
            is_first_change = True
            is_first_deletion = True
            for key in extract_table_dict:
                if key in our_table_dict:
                    # We have a record on file with this ID
                    if our_table_dict[key] == extract_table_dict[key]:
                        # print(f"✅ Value \"{extract_table_dict[key]}\" with id {str(key)} found in {table}")
                        pass
                    else:
                        print(
                            f"❌ Id {str(key)} found in {table} has a description mismatch:"
                        )
                        print("      CSV Value: ", extract_table_dict[key])
                        print("       DB Value: ", our_table_dict[key])
                        print()
                        update = f"update public.{table} set {name_component}_desc = '{escape_single_quotes(extract_table_dict[key])}' where {name_component}_id = {str(key)};"
                        if is_first_change == True:
                            changes.append(f"\n-- Changes to table {table}")
                            down_changes.append(f"\n-- Changes to table {table}")
                        changes.append(update)
                        update_down = f"update public.{table} set {name_component}_desc = '{our_table_dict[key]}' where {name_component}_id = {str(key)};"
                        down_changes.append(update_down)
                        is_first_change = False
                else:
                    # We do not have a record on file with this ID
                    print(f"❓ Id {str(key)} not found in {table}")
                    print("      CSV Value: ", extract_table_dict[key])
                    print()
                    insert = f"insert into public.{table} ({name_component}_id, {name_component}_desc) values ({str(key)}, '{escape_single_quotes(extract_table_dict[key])}');"
                    if is_first_change == True:
                        changes.append(f"\n-- Changes to table {table}")
                        down_changes.append(f"\n-- Changes to table {table}")
                    changes.append(insert)
                    insert_down = f"delete from public.{table} where {name_component}_id = {str(key)};"
                    down_changes.append(insert_down)
                    is_first_change = False
            # Now check for any values in our lookup tables that aren't in the extract and are possibly crufty
            for key in our_table_dict:
                if key not in extract_table_dict:
                    print(
                        f"❓ Id {str(key)} in our database table not found in CRIS extract for {table}"
                    )
                    print("      DB Value: ", our_table_dict[key])
                    print()
                    delete = f"delete from public.{table} where {name_component}_id = {str(key)};"
                    if is_first_deletion == True:
                        changes.append(f"\n-- Deletions from table {table}")
                        down_changes.append(f"\n-- Undo deletions from table {table}")
                    changes.append(delete)
                    delete_down = f"insert into public.{table} ({name_component}_id, {name_component}_desc) values ({str(key)}, '{escape_single_quotes(our_table_dict[key])}');"
                    down_changes.append(delete_down)
                    is_first_deletion = False

    print("\n🛠️ Here are the changes to be made:\n")
    print("\n".join(changes).strip())

    outfile = open("up_migration.sql", "w")
    outfile.write("\n".join(changes).strip())
    outfile.close()

    outfile_down = open("down_migration.sql", "w")
    outfile_down.write("\n".join(down_changes).strip())
    outfile_down.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="extract file path")
    args = parser.parse_args()
    file_path = args.input

    main(file_path)
