#!/usr/bin/env python3

import os
import psycopg2
import psycopg2.extras
import json
from dotenv import load_dotenv

load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")


def main():
    tables = get_lookup_tables('public')
    table_lengths = {}
    for table in tables:
        id_column = get_id_column(table)
        max_id = get_max_value(table, id_column)
        table_lengths[table] = max_id

        # print("Table: " + table + ", ID column: " + str(id_column))
        # print("Max ID: " + str(max_id))
        # print()

    print(table_lengths)

    for i in range(1, 10):
        test_given_substring_length(i, table_lengths)

def test_given_substring_length(length, table_lengths):
    pg = get_pg_connection()
    db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)

    print()
    print("Testing with " + str(length) + " characters of the sha1 hex value giving " + str(unique_hex_values(length)) + " possible values")

    id = 0
    used_ids = {}
    while True:
        id += 1
        # print("Input table ID: " + str(id))
        sql = f"""
        select 
            ('x'||substring(encode(digest({id}::character varying || 'cris', 'sha1'), 'hex') from 1 for {length}))::varbit::bit({length * 4})::bigint as cris,
            ('x'||substring(encode(digest({id}::character varying || 'vz',   'sha1'), 'hex') from 1 for {length}))::varbit::bit({length * 4})::bigint as vz
        """
        db.execute(sql)
        stable_ids = db.fetchone()

        cris_result = add_id_to_log(int(stable_ids['cris']), used_ids, id, table_lengths)
        vz_result = add_id_to_log(int(stable_ids['vz']), used_ids, id, table_lengths)
        if not cris_result or not vz_result:
           break 

        # print(json.dumps(used_ids, indent=4))
        # print()

def get_max_value(table, column):
    try:
        pg = get_pg_connection()
        db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)

        # print("Table: " + table + ", column: " + column)

        # Execute the query
        db.execute(f"""
            SELECT MAX({column})
            FROM {table}
        """)

        # Fetch the maximum value
        max_value = db.fetchone()[0]

        return max_value

    except Exception as e:
        print("An error occurred:", e)
        exit()
        return None


def get_id_column(s):
    if s in ['atd__recommendation_status_lkp', 'atd__mode_category_lkp', 'atd__coordination_partners_lkp']:
        return 'id'

    if s in ['atd_txdot__movt_lkp']:
        return 'movement_id'

    if s in ['atd_txdot__veh_year_lkp']:
        return 'veh_mod_year'

    # Split the string into parts using '__' as the separator
    parts = s.split('__')

    # Take the second part (assuming it exists), which should be 'base_type_lkp' in your example
    if len(parts) >= 2:
        base_part = parts[1]

        # Replace '_lkp' with '_id' in the second part
        transformed_part = base_part.replace('_lkp', '_id')

        return transformed_part
    else:
        return None


def get_lookup_tables(schema):
    try:
        pg = get_pg_connection()
        db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)

        # Execute the query
        db.execute(f"""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = '{schema}'
        """)

        # Fetch all the rows
        rows = db.fetchall()

        # Extract table names
        tables = [row[0] for row in rows]

        lkp_tables = [table for table in tables if 'lkp' in table]

        lkp_tables.remove('atd_txdot__y_n_lkp') # string value used as key

        return lkp_tables

    except Exception as e:
        print("An error occurred:", e)
        return None

def unique_hex_values(num_chars):
    return 16 ** num_chars

def find_keys_with_value_geq(d, num):
    return [key for key, value in d.items() if value >= num]

def add_id_to_log(id, log, contributing_id, table_lengths):
    if id in log:
        #print(f"Stable ID {id} already seen; namespace collision!")
        print("The maximum value of sequentially assigned IDs in either contributing table is " + str(contributing_id - 1))
        broken_tables = find_keys_with_value_geq(table_lengths, contributing_id - 1)
        print("The following tables have an ID that is too large:")
        print(broken_tables)
        return False
    else:
        log[id] = True
        return True

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

if __name__ == "__main__":
    main()
