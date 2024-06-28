#!/usr/bin/env python3

import time
import os
import glob
import psycopg2
import psycopg2.extras
from tqdm import tqdm
import json
from datetime import datetime
import decimal
import logging
import random
import shelve
import ast

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def main():

    db_connection_string = os.getenv("DATABASE_CONNECTION")

    if db_connection_string is None:
        raise EnvironmentError("DATABASE_CONNECTION environment variable is not set")

    db_files = glob.glob("./*.db")
    for db_file in db_files:
        try:
            os.remove(db_file)
        except OSError as e:
            print("Error: %s : %s" % (db_file, e.strerror))

    job = read_json_file("spreadsheet_of_columns.json")

    crashes(db_connection_string, job)
    units(db_connection_string, job)
    persons(db_connection_string, job)
    primary_persons(db_connection_string, job)


def primary_persons(db_connection_string, job):
    people_cris = shelve.open("people_cris")
    primarypersons_classic_vz = shelve.open("primarypersons_classic_vz")

    with psycopg2.connect(db_connection_string) as conn:
        # build up a dictionary of the whole table keyed on a tuple of the primary key(s)
        sql = "SELECT * FROM people_cris WHERE is_primary_person is True"
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql)

            total_count = cur.rowcount
            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of people_cris"
            )

            row = cur.fetchone()
            while row is not None:
                people_cris[
                    str((row["cris_crash_id"], row["unit_nbr"], row["prsn_nbr"]))
                ] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # another dictionary of the whole table
        sql = "SELECT * FROM atd_txdot_primaryperson"
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql)

            total_count = cur.rowcount
            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of atd_txdot_primaryperson"
            )

            row = cur.fetchone()
            while row is not None:
                primarypersons_classic_vz[
                    str((row["crash_id"], row["unit_nbr"], row["prsn_nbr"]))
                ] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()
        # random_key = random.choice(list(primarypersons_classic_vz.keys()))
        # print("Key:", random_key)
        # print("Value:", primarypersons_classic_vz[random_key])

        # cast the char Y/Ns to booleans
        for row_key, person_data in tqdm(
            primarypersons_classic_vz.items(), desc="Casting Y/N into booleans"
        ):
            for column_key, value in list(
                person_data.items()
            ):  # We use list to create a copy of items for iteration
                if column_key.endswith("_fl") and not column_key == "peh_fl":
                    if value == "Y":
                        person_data[column_key] = True
                    elif value == "N":
                        person_data[column_key] = False
                if column_key == "peh_fl" and not value:
                    person_data[column_key] = False
                primarypersons_classic_vz[row_key] = person_data

        columns = filter_by_old_table_name(job, "atd_txdot_primaryperson")

        # fmt: off
        updates = []
        for person_key in tqdm(people_cris, desc="Comparing values"):
            person_key_tuple = ast.literal_eval(person_key)
            if person_key == "(13683940, 1, 1)": # missing primaryperson in classic data
                continue
            for column in columns:
                if column["target column name"] != "-":
                    if column["target column name"] in people_cris[person_key]:
                        if (primarypersons_classic_vz[person_key][column["old column name"]] != people_cris[person_key][column["target column name"]]):
                            logging.debug(f"❌ {column['old column name']}: {primarypersons_classic_vz[person_key][column['old column name']]} != {people_cris[person_key][column['target column name']]}")
                            sql = f"update people_edits set {column['target column name']} = %s where id = (select id from people_cris where cris_crash_id = %s and unit_nbr = %s and prsn_nbr = %s)"
                            parameters = (primarypersons_classic_vz[person_key][column["old column name"]], person_key_tuple[0], person_key_tuple[1], person_key_tuple[2])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"✅ {column['old column name']}: {primarypersons_classic_vz[person_key][column['old column name']]} == {people_cris[person_key][column['target column name']]}")
                    else:
                        if primarypersons_classic_vz[person_key][column['old column name']]:
                            logging.debug(f"✨ VZ only column: No {column['target column name']} in people_cris, so {primarypersons_classic_vz[person_key][column['old column name']]} going into people_edits")
                            sql = f"update people_edits set {column['target column name']} = %s where id = (select id from people_cris where cris_crash_id = %s and unit_nbr = %s and prsn_nbr = %s)"
                            parameters = (primarypersons_classic_vz[person_key][column["old column name"]], person_key_tuple[0], person_key_tuple[1], person_key_tuple[2])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"🤷 VZ only column, but no {column['old column name']} value in classic VZ data, so no value in people_edits's {column['target column name']}")
        # fmt: on

        # Mogrify and print the queries (for debugging)
        # for update in tqdm(updates, desc="Mogrifying Queries"):
        #     with conn.cursor() as cur:
        #         mogrified_query = cur.mogrify(update[0], update[1]).decode()
        #         logging.debug(mogrified_query)

        # Execute the queries
        with conn.cursor() as cur:
            for query, params in tqdm(updates, desc="Executing Queries"):
                try:
                    cur.execute(query, params)
                except Exception as e:
                    mogrified_query = cur.mogrify(query, params).decode()
                    print("An error occurred while executing the following query:")
                    print(mogrified_query)
                    print("Error:", str(e))
                    break  # Stop executing further queries after an error


def persons(db_connection_string, job):
    people_cris = shelve.open("people_cris")
    persons_classic_vz = shelve.open("persons_classic_vz")

    with psycopg2.connect(db_connection_string) as conn:
        # build up a dictionary of the whole table keyed on a tuple of the primary key(s)
        sql = "SELECT * FROM people_cris WHERE is_primary_person is False"
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql)

            total_count = cur.rowcount
            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of people_cris"
            )

            row = cur.fetchone()
            while row is not None:
                people_cris[
                    str((row["cris_crash_id"], row["unit_nbr"], row["prsn_nbr"]))
                ] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # another dictionary of the whole table
        sql = "SELECT * FROM atd_txdot_person"
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql)

            total_count = cur.rowcount
            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of atd_txdot_person"
            )

            row = cur.fetchone()
            while row is not None:
                persons_classic_vz[
                    str((row["crash_id"], row["unit_nbr"], row["prsn_nbr"]))
                ] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # random_key = random.choice(list(persons_classic_vz.keys()))
        # print("Key:", random_key)
        # print("Value:", persons_classic_vz[random_key])

        # cast the char Y/Ns to booleans
        for row_key, person_data in tqdm(
            persons_classic_vz.items(), desc="Casting Y/N into booleans"
        ):
            for column_key, value in list(
                person_data.items()
            ):  # We use list to create a copy of items for iteration
                if column_key.endswith("_fl") and not column_key == "peh_fl":
                    if value == "Y":
                        person_data[column_key] = True
                    elif value == "N":
                        person_data[column_key] = False
                if column_key == "peh_fl" and not value:
                    person_data[column_key] = False
                persons_classic_vz[row_key] = person_data

        columns = filter_by_old_table_name(job, "atd_txdot_person")

        # fmt: off
        updates = []
        for person_key in tqdm(people_cris, desc="Comparing values"):
            person_key_tuple = ast.literal_eval(person_key)
            # print(persons_classic_vz[person_key])
            for column in columns:
                if column["target column name"] != "-":
                    if column["target column name"] in people_cris[person_key]:
                        if (persons_classic_vz[person_key][column["old column name"]] != people_cris[person_key][column["target column name"]]):
                            logging.debug(f"❌ {column['old column name']}: {persons_classic_vz[person_key][column['old column name']]} != {people_cris[person_key][column['target column name']]}")
                            sql = f"update people_edits set {column['target column name']} = %s where id = (select id from people_cris where cris_crash_id = %s and unit_nbr = %s and prsn_nbr = %s)"
                            parameters = (persons_classic_vz[person_key][column["old column name"]], person_key_tuple[0], person_key_tuple[1], person_key_tuple[2])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"✅ {column['old column name']}: {persons_classic_vz[person_key][column['old column name']]} == {people_cris[person_key][column['target column name']]}")
                    else:
                        if persons_classic_vz[person_key][column['old column name']]:
                            logging.debug(f"✨ VZ only column: No {column['target column name']} in people_cris, so {persons_classic_vz[person_key][column['old column name']]} going into people_edits")
                            sql = f"update people_edits set {column['target column name']} = %s where id = (select id from people_cris where cris_crash_id = %s and unit_nbr = %s and prsn_nbr = %s)"
                            parameters = (persons_classic_vz[person_key][column["old column name"]], person_key_tuple[0], person_key_tuple[1], person_key_tuple[2])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"🤷 VZ only column, but no {column['old column name']} value in classic VZ data, so no value in people_edits's {column['target column name']}")
        # fmt: on

        # Mogrify and print the queries (for debugging)
        # for update in tqdm(updates, desc="Mogrifying Queries"):
        #     with conn.cursor() as cur:
        #         mogrified_query = cur.mogrify(update[0], update[1]).decode()
        #         logging.debug(mogrified_query)

        # Execute the queries
        with conn.cursor() as cur:
            for query, params in tqdm(updates, desc="Executing Queries"):
                try:
                    cur.execute(query, params)
                except Exception as e:
                    mogrified_query = cur.mogrify(query, params).decode()
                    print("An error occurred while executing the following query:")
                    print(mogrified_query)
                    print("Error:", str(e))
                    break  # Stop executing further queries after an error


def units(db_connection_string, job):
    units_cris = shelve.open("units_cris")
    units_classic_vz = shelve.open("units_classic_vz")

    with psycopg2.connect(db_connection_string) as conn:
        # build up a dictionary of the whole table keyed on a tuple of the primary key(s)
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT COUNT(*) as count FROM units_cris")
            total_count = cur.fetchone()["count"]

            cur.execute("SELECT * FROM units_cris")

            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of units_cris"
            )

            row = cur.fetchone()
            while row is not None:
                units_cris[str((row["cris_crash_id"], row["unit_nbr"]))] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # another dictionary of the whole table
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT COUNT(*) as count FROM atd_txdot_units")
            total_count = cur.fetchone()["count"]

            cur.execute("SELECT * FROM atd_txdot_units")

            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of atd_txdot_units"
            )

            row = cur.fetchone()
            while row is not None:
                units_classic_vz[str((row["crash_id"], row["unit_nbr"]))] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # cast the char Y/Ns to booleans
        for row_key, unit_data in tqdm(
            units_classic_vz.items(), desc="Casting Y/N into booleans"
        ):
            for column_key, value in list(
                unit_data.items()
            ):  # We use list to create a copy of items for iteration
                if column_key.endswith("_fl"):
                    if value == "Y":
                        unit_data[column_key] = True
                    elif value == "N":
                        unit_data[column_key] = False
                units_classic_vz[row_key] = unit_data

        columns = filter_by_old_table_name(job, "atd_txdot_units")

        # fmt: off
        updates = []
        for unit_key in tqdm(units_cris, desc="Comparing values"):
            unit_key_tuple = ast.literal_eval(unit_key)
            for column in columns:
                if column["target column name"] != "-":
                    if column["target column name"] in units_cris[unit_key]:
                        if (units_classic_vz[unit_key][column["old column name"]] != units_cris[unit_key][column["target column name"]]):
                            logging.debug(f"❌ {column['old column name']}: {units_classic_vz[unit_key][column['old column name']]} != {units_cris[unit_key][column['target column name']]}")
                            sql = f"update units_edits set {column['target column name']} = %s where id = (select id from units_cris where cris_crash_id = %s and unit_nbr = %s)"
                            parameters = (units_classic_vz[unit_key][column["old column name"]], unit_key_tuple[0], unit_key_tuple[1])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"✅ {column['old column name']}: {units_classic_vz[unit_key][column['old column name']]} == {units_cris[unit_key][column['target column name']]}")
                    else:
                        if units_classic_vz[unit_key][column['old column name']]:
                            logging.debug(f"✨ VZ only column: No {column['target column name']} in units_cris, so {units_classic_vz[unit_key][column['old column name']]} going into units_edits")
                            sql = f"update units_edits set {column['target column name']} = %s where id = (select id from units_cris where cris_crash_id = %s and unit_nbr = %s)"
                            parameters = (units_classic_vz[unit_key][column["old column name"]], unit_key_tuple[0], unit_key_tuple[1])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"🤷 VZ only column, but no {column['old column name']} in classic VZ data, so no value in units_edits's {column['target column name']}")
        # fmt: on

        # Mogrify and print the queries (for debugging)
        # for update in tqdm(updates, desc="Mogrifying Queries"):
        #     with conn.cursor() as cur:
        #         mogrified_query = cur.mogrify(update[0], update[1]).decode()
        #         logging.debug(mogrified_query)

        # Execute the queries
        with conn.cursor() as cur:
            for query, params in tqdm(updates, desc="Executing Queries"):
                cur.execute(query, params)


def crashes(db_connection_string, job):

    crashes_cris = shelve.open("crashes_cris")
    crashes_classic_vz = shelve.open("crashes_classic_vz")

    with psycopg2.connect(db_connection_string) as conn:
        # build up a mondo dictionary of the whole table keyed on a tuple of the primary key(s)
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT COUNT(id) as count FROM crashes_cris")
            total_count = cur.fetchone()["count"]

            cur.execute("SELECT * FROM crashes_cris")

            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of crashes_cris"
            )

            row = cur.fetchone()
            while row is not None:
                crashes_cris[str((row["crash_id"],))] = (
                    row  # casting to str because no .encode() on tuple
                )
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # another big dictionary of the whole table
        sql = "select * from atd_txdot_crashes"
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT COUNT(crash_id) as count FROM atd_txdot_crashes")
            total_count = cur.fetchone()["count"]

            cur.execute("SELECT * FROM atd_txdot_crashes")

            progress_bar = tqdm(
                total=total_count, desc="Building dictionary of atd_txdot_crashes"
            )

            row = cur.fetchone()
            while row is not None:
                crashes_classic_vz[str((row["crash_id"],))] = dict(row)
                row = cur.fetchone()
                progress_bar.update()

            progress_bar.close()

        # cast the char Y/Ns to booleans
        for row_key, crash_data in tqdm(
            crashes_classic_vz.items(), desc="Casting Y/N into booleans"
        ):
            for column_key, value in list(
                crash_data.items()
            ):  # We use list to create a copy of items for iteration
                if column_key.endswith("_fl"):
                    if value == "Y":
                        crash_data[column_key] = True
                    elif value == "N":
                        crash_data[column_key] = False
                crashes_classic_vz[row_key] = crash_data

        # cast floats into decimals
        for row_key, crash_data in tqdm(
            crashes_classic_vz.items(),
            desc="Casting geographic coordinates into fixed precision",
        ):
            for column_key, value in list(
                crash_data.items()
            ):  # We use list to create a copy of items for iteration
                if (
                    "latitude" in column_key
                    or "longitude" in column_key
                    and value is not None
                ):
                    try:
                        crash_data[column_key] = decimal.Decimal(str(value))
                    except decimal.InvalidOperation:
                        # unparsable value, like a 'None', no big.
                        pass
                crashes_classic_vz[row_key] = crash_data

        columns = filter_by_old_table_name(job, "atd_txdot_crashes")

        # fmt: off
        updates = []
        for crash_key in tqdm(crashes_cris, desc="Comparing values"):
            crash_key_tuple = ast.literal_eval(crash_key)
            for column in columns:
                if column["target column name"] != "-":
                    if column["target column name"] in crashes_cris[crash_key]:
                        if (crashes_classic_vz[crash_key][column["old column name"]] != crashes_cris[crash_key][column["target column name"]]):
                            logging.debug(f"❌ {column['old column name']}: {crashes_classic_vz[crash_key][column['old column name']]} != {crashes_cris[crash_key][column['target column name']]}")
                            sql = f"update crashes_edits set {column['target column name']} = %s where id = (select id from crashes_cris where crash_id = %s)"
                            parameters = (crashes_classic_vz[crash_key][column["old column name"]], crash_key_tuple[0])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"✅ {column['old column name']}: {crashes_classic_vz[crash_key][column['old column name']]} == {crashes_cris[crash_key][column['target column name']]}")
                    else:
                        if crashes_classic_vz[crash_key][column['old column name']]:
                            logging.debug(f"✨ VZ only column: No {column['target column name']} in crashes_cris, so {crashes_classic_vz[crash_key][column['old column name']]} going into crashes_edits")
                            sql = f"update crashes_edits set {column['target column name']} = %s where id = (select id from crashes_cris where crash_id = %s)"
                            parameters = (crashes_classic_vz[crash_key][column["old column name"]], crash_key_tuple[0])
                            updates.append((sql, parameters))
                        else:
                            logging.debug(f"🤷 VZ only column, but no {column['old column name']} in classic VZ data, so no value in crashes_edits's {column['target column name']}")
        # fmt: on

        # Mogrify and print the queries (for debugging)
        # for update in tqdm(updates, desc="Mogrifying Queries"):
        #     with conn.cursor() as cur:
        #         mogrified_query = cur.mogrify(update[0], update[1]).decode()
        #         logging.debug(mogrified_query)

        # Execute the queries
        with conn.cursor() as cur:
            for query, params in tqdm(updates, desc="Executing Queries"):
                cur.execute(query, params)


def filter_by_old_table_name(data, table_name):
    return [item for item in data if item["old table name"] == table_name]


def read_json_file(file_path):
    with open(file_path, "r") as json_file:
        data = json.load(json_file)
    return data


if __name__ == "__main__":
    main()
