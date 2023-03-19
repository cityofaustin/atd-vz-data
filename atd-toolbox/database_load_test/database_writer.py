#!/usr/bin/env python3

import os
import psycopg2
import psycopg2.extras
import random
from dotenv import load_dotenv
from faker import Faker
from faker.providers import lorem, date_time, python, misc

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_RR_HOST = os.getenv("DB_RR_HOST")
DB_DATABASE = os.getenv("DB_DATABASE")
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_PORT = os.getenv("DB_PORT")

def main():
    # check_sanity()
    tables = ["atd_txdot_crashes"]
    for table in tables:
        print("Table: ", table)
        shape = get_table_shape(table)
        # print("Shape: ", shape)
        insert_sql = build_insert_sql(table, shape)

def check_sanity():
    print("Ask yourself: Am I very sure this isn't pointed at a production database?")
    input("Press Enter to continue...")

def get_primary_connection():
    # print("DB_HOST: ", DB_HOST)
    primary = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USERNAME, 
        password=DB_PASSWORD, 
        dbname=DB_DATABASE, 
        sslmode="require" 
        )
    return primary

def get_rr_connection():
    # print("DB_RR_HOST: ", DB_RR_HOST)
    rr = psycopg2.connect(
        host=DB_RR_HOST,
        port=DB_PORT,
        user=DB_USERNAME, 
        password=DB_PASSWORD, 
        dbname=DB_DATABASE, 
        sslmode="require" 
        )
    return rr

def get_table_shape(table):
    primary = get_primary_connection()
    table_shape_sql = f"""
    SELECT
        column_name, 
        ordinal_position, 
        data_type, 
        character_maximum_length, 
        numeric_precision,
        numeric_scale
    FROM information_schema.columns
    WHERE true
        AND table_schema = 'public'
        AND table_name   = '{table}';
    """
    # print("Table shape SQL: ", table_shape_sql)

    cursor = primary.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cursor.execute(table_shape_sql)
    table_shape = cursor.fetchall()
    return table_shape

def build_insert_sql(table, shape):

    fields = []
    values = []
    placeholders = []
    for field in shape:
        print("Field: ", field["column_name"])
        print("Type:  ", field["data_type"])

        # 🤖 🦾 Copilot was made for this sort of thing
        if table == 'atd_txdot_crashes' and field["column_name"] == 'crash_id':
            fields.append(field["column_name"])
            values.append(get_next_crash_id())
        elif table == 'atd_txdot_crashes' and field["column_name"] == 'position':
            fields.append(field["column_name"])
            values.append(random_position())
        elif field["data_type"] == 'character varying':
            fields.append(field["column_name"])
            values.append(random_character_varying(field))
        elif field["data_type"] == 'integer':
            fields.append(field["column_name"])
            values.append(random_integer(field))
        elif field["data_type"] == 'date':
            fields.append(field["column_name"])
            values.append(random_date(field))
        elif field["data_type"] == 'timestamp with time zone':
            fields.append(field["column_name"])
            values.append(random_timestamp_with_time_zone(field))
        elif field["data_type"] == 'timestamp without time zone':
            fields.append(field["column_name"])
            values.append(random_timestamp_without_time_zone(field))
        elif field["data_type"] == 'time with time zone':
            fields.append(field["column_name"])
            values.append(random_time_with_time_zone(field))
        elif field["data_type"] == 'time without time zone':
            fields.append(field["column_name"])
            values.append(random_time_without_time_zone(field))
        elif field["data_type"] == 'double precision':
            fields.append(field["column_name"])
            values.append(random_double_precision(field))
        elif field["data_type"] == 'text':
            fields.append(field["column_name"])
            values.append(random_text(field))
        elif field["data_type"] == 'boolean':
            fields.append(field["column_name"])
            values.append(random_boolean(field))
        elif field["data_type"] == 'numeric':
            fields.append(field["column_name"])
            values.append(random_numeric(field))
        elif field["data_type"] == 'json':
            fields.append(field["column_name"])
            values.append(random_json(field))
        elif field["data_type"] == 'jsonb':
            fields.append(field["column_name"])
            values.append(random_jsonb(field))
        else:
            quit()

        placeholders.append("%s")
    print("Done")

def random_character_varying(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(lorem)
    string = fake.paragraph()[:field["character_maximum_length"]]
    # print("Fake Letter: ", string)
    return string

def random_integer(field):
    # print("Field: ", field)
    integer = random.randint(0, 2**field["numeric_precision"])
    # print("Fake Integer: ", integer)
    return integer

def random_date(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(date_time)
    date = fake.date_this_year()
    # print("Date: ", date)
    return date

def random_timestamp_with_time_zone(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(date_time)
    timestamp = fake.date_time_this_year()
    return timestamp
    # print("Timestamp: ", timestamp)

def random_timestamp_without_time_zone(field):
    return random_timestamp_with_time_zone(field)

def random_time_with_time_zone(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(date_time)
    time = fake.time()
    # print("Time: ", time)

def random_time_without_time_zone(field):
    return random_time_with_time_zone(field)

def random_double_precision(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(python)
    float = fake.pyfloat()
    # print("Float: ", float)

def random_text(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(lorem)
    string = "\n".join(fake.paragraphs(nb=5))
    # print("Fake text: ", string)
    return string

def random_boolean(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(python)
    boolean = fake.pybool()
    # print("Fake Boolean: ", boolean)
    return boolean

def random_numeric(field):
    # print("Field: ", field)
    if not field["numeric_scale"]:
        field["numeric_scale"] = 2
    if not field["numeric_precision"]:
        field["numeric_precision"] = 10
    precision = field["numeric_precision"] - field["numeric_scale"]
    fake = Faker()
    fake.add_provider(python)
    # these names feel backwards, but this is what it is
    numeric = fake.pyfloat(left_digits=precision, right_digits=field["numeric_scale"])
    # print("Fake Numeric: ", numeric)
    return numeric

def random_json(field):
    # print("Field: ", field)
    fake = Faker()
    fake.add_provider(misc)
    json = fake.json()
    # print("json: ", json)
    return json

def random_jsonb(field):
    return random_json(field)

def random_position():
    latitude = 30.274722 + random.uniform(-0.1, 0.1)
    longitude = -97.740556 + random.uniform(-0.1, 0.1)
    print("Latitude: ", latitude)
    print("Longitude: ", longitude)
    position = f"ST_GeomFromEWKT('SRID=4326;POINT({longitude} {latitude})')"
    # print("Position", position)
    return position
    pass

def get_next_crash_id():
    primary = get_primary_connection()
    cursor = primary.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cursor.execute("SELECT max(crash_id)+1 as next_id FROM atd_txdot_crashes;")
    next_crash_id = cursor.fetchone()["next_id"]
    # print("Got Next Crash ID: ", next_crash_id)
    return next_crash_id


if __name__ == "__main__":
    main()