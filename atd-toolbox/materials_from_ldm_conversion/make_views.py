#!/usr/bin/env python3

import os
import psycopg2
import psycopg2.extras
import datetime
from dotenv import load_dotenv

load_dotenv("env")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_SSL_REQUIREMENT = os.getenv("DB_SSL_REQUIREMENT")


def main():
    create_schema()
    make_crashes_view()

def make_crashes_view():
    pg = get_pg_connection()
    db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)
    sql = """
    SELECT
        column_name, data_type, udt_name, character_maximum_length, numeric_precision,
        numeric_precision, numeric_scale, is_generated, generation_expression, is_updatable
    FROM information_schema.columns
    WHERE true
        AND table_schema = 'vz'
        AND table_name = 'atd_txdot_crashes'
    order by ordinal_position
    ;
    """
    db.execute(sql)

    view = """
    create view ldm.atd_txdot_crashes as
        select
            cris.atd_txdot_crashes.crash_id,
    """
    while column := db.fetchone():
        print(column)
    pass

def create_schema():
    pg = get_pg_connection()
    db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)

    db.execute("DROP SCHEMA IF EXISTS ldm CASCADE;")
    pg.commit()

    db.execute("CREATE SCHEMA IF NOT EXISTS ldm;")
    pg.commit()

    db.close()
    pg.close()

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