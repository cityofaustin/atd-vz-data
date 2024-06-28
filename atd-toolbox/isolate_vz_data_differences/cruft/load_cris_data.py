#!/usr/bin/env python3

import os
import subprocess
import csv
import psycopg2

# Global dictionary to store tables and their columns
tables_columns = {}


def process_file(csv_file_path, db_connection_string, output_dir):
    # Get the base name of the CSV file to use as the command file name
    base_name = os.path.basename(csv_file_path)
    table_name = base_name.split("_")[3].lower()
    print("Starting a new file for table", table_name)
    if table_name not in ["crash", "unit", "person", "primaryperson", "charges"]:
        return

    with open(csv_file_path, "r") as csv_file:
        csv_reader = csv.reader(csv_file)
        headers = [header.lower() for header in next(csv_reader)]
        # Update the global dictionary if new headers are found
        if table_name not in tables_columns:
            tables_columns[table_name] = headers

        with psycopg2.connect(db_connection_string) as conn:
            # Create a cursor object
            with conn.cursor() as cur:
                # Check if the table exists
                cur.execute(
                    f"""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE  table_schema = 'data_model' 
                        AND    table_name   = '{table_name.lower()}'
                    );
                    """
                )
                table_exists = cur.fetchone()[0]

                if not table_exists:
                    # This is the first time we're seeing this table, so create it
                    columns = ", ".join(f'"{header}" VARCHAR' for header in headers)
                    create_table_query = f"CREATE TABLE IF NOT EXISTS data_model.{table_name} ({columns});"
                    print("Creating table", table_name)
                    cur.execute(create_table_query)
                else:
                    # We've seen this table before, so check if there are any new columns
                    new_columns = [
                        header
                        for header in headers
                        if header not in tables_columns[table_name]
                    ]
                    for new_column in new_columns:
                        alter_table_query = f"ALTER TABLE data_model.{table_name} ADD COLUMN {new_column} VARCHAR;"
                        print(f"Adding column {new_column} to table {table_name}")
                        tables_columns[table_name].append(new_column)
                        cur.execute(alter_table_query)
                conn.commit()

            with conn.cursor() as cur:
                rows_to_insert = []
                for row in csv_reader:
                    row_dict = dict(zip(headers, row))
                    rows_to_insert.append(row_dict)

                    batch_size = 10000

                    if len(rows_to_insert) >= batch_size:
                        # Construct the INSERT INTO SQL query
                        columns = ", ".join(rows_to_insert[0].keys())
                        placeholders = ", ".join(["%s"] * len(rows_to_insert[0]))
                        insert_query = f"INSERT INTO data_model.{table_name} ({columns}) VALUES ({placeholders});"

                        # Execute the SQL query
                        cur.executemany(
                            insert_query, [list(row.values()) for row in rows_to_insert]
                        )

                        # Clear rows_to_insert and commit the transaction
                        rows_to_insert = []
                        print(f"Inserted {batch_size} rows")
                        conn.commit()

                # Insert any remaining rows
                if rows_to_insert:
                    # Construct the INSERT INTO SQL query
                    columns = ", ".join(rows_to_insert[0].keys())
                    placeholders = ", ".join(["%s"] * len(rows_to_insert[0]))
                    insert_query = f"INSERT INTO data_model.{table_name} ({columns}) VALUES ({placeholders});"

                    # Execute the SQL query
                    print(f"Inserting {len(rows_to_insert)} rows")
                    cur.executemany(
                        insert_query, [list(row.values()) for row in rows_to_insert]
                    )

                conn.commit()


def process_directory(root_dir, db_connection_string, output_dir, only_file=None):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".csv") and (only_file is None or file == only_file):
                csv_file_path = os.path.join(subdir, file)
                process_file(csv_file_path, db_connection_string, output_dir)


def drop_tables(db_connection_string):
    # List of tables to drop
    tables = [
        "charges",
        "crash",
        "damages",
        "endorsements",
        "lookup",
        "person",
        "primaryperson",
        "restrictions",
        "unit",
    ]

    with psycopg2.connect(db_connection_string) as conn:
        with conn.cursor() as cur:
            for table in tables:
                print(f"Dropping table data_model.{table}")
                cur.execute(f"DROP TABLE IF EXISTS data_model.{table};")
        conn.commit()


def create_schema(db_connection_string):
    with psycopg2.connect(db_connection_string) as conn:
        with conn.cursor() as cur:
            # Execute the SQL command to create the schema
            print("Creating schema data_model if it does not exist")
            cur.execute("CREATE SCHEMA IF NOT EXISTS data_model;")
        conn.commit()


if __name__ == "__main__":
    root_dir = "/app/extracts"
    output_dir = "/app/load_files"

    db_connection_string = os.getenv("DATABASE_CONNECTION")

    if db_connection_string is None:
        raise EnvironmentError("DATABASE_CONNECTION environment variable is not set")

    create_schema(db_connection_string)
    drop_tables(db_connection_string)
    process_directory(root_dir, db_connection_string, output_dir)
