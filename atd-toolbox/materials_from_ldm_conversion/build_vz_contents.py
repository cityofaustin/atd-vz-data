#!/usr/bin/env python3

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

def values_for_sql(values):
    strings = []
    for value in values:
        # print(value, type(value))
        # print(value, isinstance(value, datetime.datetime))
        if isinstance(value, str):
            strings.append(f"'{value}'")
        elif isinstance(value, datetime.date):
            strings.append(f"'{str(value)}'")
        elif isinstance(value, datetime.datetime):
            strings.append(f"'{str(value)}'")
        elif value is None:
            strings.append("null")
        else:
            strings.append(f"{str(value)}")
    return strings

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

pg = get_pg_connection()
cris_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
public_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
vz_cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

vz_cursor.execute('truncate vz.atd_txdot_crashes')
pg.commit()

sql = "select * from cris.atd_txdot_crashes order by crash_id asc"
cris_cursor.execute(sql)
for cris in cris_cursor:
    print()
    print("CRIS:   ", cris["crash_id"])
    sql = "select * from public.atd_txdot_crashes where crash_id = %s"
    public_cursor.execute(sql, (cris["crash_id"],))
    public = public_cursor.fetchone()
    print("public: ", public["crash_id"])
    keys = ["crash_id"]
    values = [cris["crash_id"]]
    for k, v in cris.items():
        if (k in ('crash_id')): # use to define fields to ignore
            continue
        if v != public[k]:
            # print("Δ ", k, ": ", public[k], " → ", v)
            keys.append(k)
            values.append(v)
    print("keys: ", keys)
    print("values: ", values)
    comma_linefeed = ",\n        "
    sql = f"""
    insert into vz_atd_txdot_crashes (
        {comma_linefeed.join(keys)}
    ) values (
        {comma_linefeed.join(values_for_sql(values))}
    )
    """
    print(sql)
    input("Press Enter to continue...")