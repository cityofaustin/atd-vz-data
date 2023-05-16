#!/usr/bin/env python3

import argparse
import csv
from collections import defaultdict
import os
import psycopg2
import psycopg2.extras
import re

from dotenv import load_dotenv

load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")

def main():
    parser = argparse.ArgumentParser(description="Process CRIS lookup table CSV files")
    parser.add_argument('-i', '--input', required=True, help='Input CSV file')
    args = parser.parse_args()

    schemata = ['cris_lookup', 'vz_lookup']
    drop_and_recreate_schemas(schemata)
    drop_and_recreate_schemas(['lookup'])

    data_dict = read_csv_into_dict(args.input)

    # Print data_dict for verification
    for key in data_dict:
        print("Key: " + key)
        table = transform_input(key)
        print("Table: " + table)
        #print(f'{key}: {data_dict[key]}')
        for schema in schemata:
            create_table(schema, table)
        populate_table(schemata[0], table, data_dict[key])
        create_materialized_view('lookup', table)
        if check_for_duplicates('lookup', table):
            raise Exception(f"Namespace Collision in Lookup Table: {table}")

def check_for_duplicates(schema, table_name):
    try:
        conn = get_pg_connection()
        cur = conn.cursor()

        cur.execute(f"""
            SELECT id
            FROM {schema}.{table_name}
            GROUP BY id
            HAVING COUNT(id) > 1;
        """)

        result = cur.fetchall()
        cur.close()
        conn.close()

        if result:
            print("🔥 Duplicate IDs found:")
            for row in result:
                print(row[0])
            return True
        else:
            # print("No duplicate IDs found.")
            return False

    except Exception as e:
        print(f"An error occurred: {e}")
        return False


def create_materialized_view(schema, view_name):
    try:
        conn = get_pg_connection()
        cur = conn.cursor()

        cur.execute(f"""
            CREATE MATERIALIZED VIEW {schema}.{view_name} AS
            SELECT 
                ('x'||substring(encode(digest(id::character varying || 'vz', 'sha1'), 'hex') from 1 for 7))::varbit::bit(28)::integer as id,
                description
            FROM cris_lookup.{view_name}
            WHERE active IS TRUE
            UNION ALL
            SELECT 
                ('x'||substring(encode(digest(id::character varying || 'cris', 'sha1'), 'hex') from 1 for 7))::varbit::bit(28)::integer as id,
                description
            FROM vz_lookup.{view_name}
            WHERE active IS TRUE
        """)

        conn.commit()
        cur.close()
        conn.close()
        return True

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def populate_table(schema, table_name, data_list):
    try:
        conn = get_pg_connection()
        cur = conn.cursor()
        
        for data in data_list:
            cur.execute(
                f"INSERT INTO {schema}.{table_name} (upstream_id, description) VALUES (%s, %s);",
                (data['id'], data['description'])
            )

        conn.commit()
        cur.close()
        conn.close()
        return True

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def create_table(schema, table_name):
    try:
        conn = get_pg_connection()
        cur = conn.cursor()

        cur.execute(f"""
            CREATE TABLE {schema}.{table_name} (
                id SERIAL PRIMARY KEY,
                upstream_id INTEGER,
                description TEXT,
                active BOOLEAN DEFAULT TRUE
            );
        """)

        conn.commit()
        cur.close()
        conn.close()
        return True

    except Exception as e:
        print(f"An error occurred: {e}")
        return False



def transform_input(input_string):
    # Transform to lowercase
    transformed_string = input_string.lower()
    
    # Remove trailing "_id" if present
    transformed_string = re.sub("_id$", "", transformed_string)
    
    return transformed_string


def drop_and_recreate_schemas(schema_list):
    try:
        conn = get_pg_connection()
        cur = conn.cursor()

        # Start a new transaction
        cur.execute("BEGIN;")
        
        for schema in schema_list:
            # Drop the schema if it exists
            cur.execute(f"DROP SCHEMA IF EXISTS {schema} CASCADE;")

        for schema in schema_list:
            # Recreate the schema
            cur.execute(f"CREATE SCHEMA {schema};")

        # Commit the transaction
        cur.execute("COMMIT;")
        
        cur.close()
        conn.close()
        return True

    except Exception as e:
        print(f"An error occurred: {e}")
        return False


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

def read_csv_into_dict(file_path):
    data_dict = defaultdict(list)
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader, None)  # Skip the header
        for row in reader:
            data_dict[row[0]].append({'id': row[1], 'description': row[2]})
    return data_dict


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)