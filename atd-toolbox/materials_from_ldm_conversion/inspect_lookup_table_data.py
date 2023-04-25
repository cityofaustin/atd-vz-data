#!/usr/bin/env python

import csv
import json

import re
import os
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

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

def read_and_group_csv(file_path):
    grouped_data = {}

    with open(file_path, newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')
        
        # Skip the first row (header)
        next(csvreader)
        
        for row in csvreader:
            key = row[0]
            inner_dict = {
                'id': int(row[1]),
                'description': row[2]
            }

            if key not in grouped_data:
                grouped_data[key] = []

            grouped_data[key].append(inner_dict)

    return grouped_data

file_path = '/home/frank/atd-vz-data/atd-toolbox/materials_from_ldm_conversion/lookup_data/' + 'extract_2023_20230424123049_lookup_20230401_HAYSTRAVISWILLIAMSON.csv'
data = read_and_group_csv(file_path)

# Pretty-print the grouped data as JSON
print(json.dumps(data, indent=4))


def main():
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    for table in data:
        match = re.search(r"(^.*)_ID$", table)
        table_name = "atd_txdot__" + match.group(1).lower() + "_lkp"
        print(table_name)
        

if __name__ == "__main__":
    main()