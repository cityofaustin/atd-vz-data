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


def main():
    create_schema()
    make_crashes_view()
    make_units_view()

def make_crashes_view():
    pg = get_pg_connection()
    db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)
    
    db.execute("drop view if exists ldm.atd_txdot_crashes;")
    pg.commit()


    sql = """
    with vz as (
        select
            'vz' as schema, ordinal_position,
            column_name, data_type, udt_name, character_maximum_length, numeric_precision,
            numeric_precision, numeric_scale, is_generated, generation_expression, is_updatable
        FROM information_schema.columns
        WHERE true
            AND table_schema = 'vz'
            AND table_name = 'atd_txdot_crashes'
        order by ordinal_position
        ), cris as (
        SELECT
            'cris' as schema, ordinal_position,
            column_name, data_type, udt_name, character_maximum_length, numeric_precision,
            numeric_precision, numeric_scale, is_generated, generation_expression, is_updatable
        FROM information_schema.columns
        WHERE true
            AND table_schema = 'cris'
            AND table_name = 'atd_txdot_crashes'
        order by ordinal_position
        )
    select vz.column_name as vz_column_name, cris.column_name as cris_column_name,
        case when vz.column_name is not null then vz.schema
            when cris.column_name is not null then cris.schema
        end as schema,
        case when vz.column_name is not null then vz.column_name
            when cris.column_name is not null then cris.column_name
        end as column_name
    from vz
        full outer join cris on (vz.column_name = cris.column_name)
    where true 
        and (vz.column_name not in ('crash_id') or cris.column_name not in ('crash_id'))
    order by coalesce(vz.ordinal_position, cris.ordinal_position)
    """
    db.execute(sql)


    view = """
    create view ldm.atd_txdot_crashes as
        select
            cris.atd_txdot_crashes.crash_id as crash_id,
        """
    columns = []
    for column in db:
        if column["vz_column_name"] is not None and column["cris_column_name"] is None:
            columns.append(f'vz.atd_txdot_crashes.{column["column_name"]}')
        elif column["cris_column_name"] is not None and column["vz_column_name"] is None:
            columns.append(f'cris.atd_txdot_crashes.{column["column_name"]}')
        else:
            columns.append(f'coalesce(vz.atd_txdot_crashes.{column["column_name"]}, cris.atd_txdot_crashes.{column["column_name"]}) as {column["column_name"]}')
    view = view + "    " + ", \n            ".join(columns)
    view = view + """
        from vz.atd_txdot_crashes
        join cris.atd_txdot_crashes
            on vz.atd_txdot_crashes.crash_id = cris.atd_txdot_crashes.crash_id
                """
    print(view)
    db.execute(view)
    pg.commit()

def make_units_view():
    pg = get_pg_connection()
    db = pg.cursor(cursor_factory=psycopg2.extras.DictCursor)
    
    db.execute("drop view if exists ldm.atd_txdot_units;")
    pg.commit()


    sql = """
    with vz as (
        select
            'vz' as schema, ordinal_position,
            column_name, data_type, udt_name, character_maximum_length, numeric_precision,
            numeric_precision, numeric_scale, is_generated, generation_expression, is_updatable
        FROM information_schema.columns
        WHERE true
            AND table_schema = 'vz'
            AND table_name = 'atd_txdot_units'
        order by ordinal_position
        ), cris as (
        SELECT
            'cris' as schema, ordinal_position,
            column_name, data_type, udt_name, character_maximum_length, numeric_precision,
            numeric_precision, numeric_scale, is_generated, generation_expression, is_updatable
        FROM information_schema.columns
        WHERE true
            AND table_schema = 'cris'
            AND table_name = 'atd_txdot_units'
        order by ordinal_position
        )
    select vz.column_name as vz_column_name, cris.column_name as cris_column_name,
        case when vz.column_name is not null then vz.schema
            when cris.column_name is not null then cris.schema
        end as schema,
        case when vz.column_name is not null then vz.column_name
            when cris.column_name is not null then cris.column_name
        end as column_name
    from vz
        full outer join cris on (vz.column_name = cris.column_name)
    where true 
        and (vz.column_name not in ('crash_id') or cris.column_name not in ('crash_id'))
    order by coalesce(vz.ordinal_position, cris.ordinal_position)
    """
    db.execute(sql)


    view = """
    create view ldm.atd_txdot_units as
        select
            cris.atd_txdot_units.crash_id as crash_id,
        """
    columns = []
    for column in db:
        if column["vz_column_name"] is not None and column["cris_column_name"] is None:
            columns.append(f'vz.atd_txdot_units.{column["column_name"]}')
        elif column["cris_column_name"] is not None and column["vz_column_name"] is None:
            columns.append(f'cris.atd_txdot_units.{column["column_name"]}')
        else:
            columns.append(f'coalesce(vz.atd_txdot_units.{column["column_name"]}, cris.atd_txdot_units.{column["column_name"]}) as {column["column_name"]}')
    view = view + "    " + ", \n            ".join(columns)
    view = view + """
        from vz.atd_txdot_units
        join cris.atd_txdot_units
            on  (
                    vz.atd_txdot_units.crash_id = cris.atd_txdot_units.crash_id
                and vz.atd_txdot_units.unit_nbr = cris.atd_txdot_units.unit_nbr
                )
                """
    print(view)
    db.execute(view)
    pg.commit()

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