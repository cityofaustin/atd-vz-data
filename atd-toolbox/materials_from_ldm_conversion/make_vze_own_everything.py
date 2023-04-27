#!/usr/bin/env python

import os
import psycopg2
import psycopg2.extras
import datetime

#from dotenv import load_dotenv
#load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")

def main():
    #possible_schemas = ['cris', 'hdb_catalog', 'import', 'ldm', 'public', 'vz']
    possible_schemas = ['public'] # for our production replica
    for schema in possible_schemas:
        if check_schema_exists(schema):
            print(f"Schema {schema} exists")
            make_schema_owner(schema)
            tables = get_tables_in_schema(schema)
            for table in tables: # and views too
                print(f"Changing owner of {table['table_name']} to vze")
                change_table_owner(schema, table['table_name'])

def change_table_owner(schema, table):
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    sql = f"""
        ALTER TABLE {schema}.{table} OWNER TO vze;
        """

    print(sql)

    cursor.execute(sql)
    pg.commit()

def get_tables_in_schema(schema):
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    sql = f"""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = '{schema}';
        """
    cursor.execute(sql)
    records = cursor.fetchall()
    return records

def make_schema_owner(schema):
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    sql = f"""
        ALTER SCHEMA {schema} OWNER TO vze;
        """
    cursor.execute(sql)
    pg.commit()

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
    )

def check_schema_exists(schema):
    pg = get_pg_connection()
    cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    sql = f"""
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name = '{schema}';
        """
    cursor.execute(sql)
    record = cursor.fetchone()
    if (record):
        return True
    return False

if __name__ == "__main__":
    main()