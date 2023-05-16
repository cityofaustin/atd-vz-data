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
    parser.add_argument('-c', '--create', action='store_true', help='Create a new file if set')
    args = parser.parse_args()

    data_dict = read_csv_into_dict(args.input)

    # Print data_dict for verification
    for key in data_dict:
        print("Key: " + key)
        #print(f'{key}: {data_dict[key]}')

    drop_and_recreate_schemas(['cris_lookup', 'vz_lookup'])

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
    main()
