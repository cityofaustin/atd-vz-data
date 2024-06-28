#!/usr/bin/env python3

import os
import psycopg2
import psycopg2.extras
from tqdm import tqdm
import json
from datetime import datetime


def main():

    db_connection_string = os.getenv("DATABASE_CONNECTION")

    if db_connection_string is None:
        raise EnvironmentError("DATABASE_CONNECTION environment variable is not set")

    table_sets = [
        (
            "atd_txdot_crashes",
            "crash",
            "crashes_cris",
            "crashes_edits",
            "id",
            ("crash_id",),
        ),
        (
            "atd_txdot_units",
            "unit",
            "units_cris",
            "units_edits",
            "id",
            ("crash_id", "unit_nbr"),
        ),
        (
            "atd_txdot_primaryperson",
            "primaryperson",
            "people_cris",
            "people_edits",
            "id",
            ("crash_id", "unit_nbr", "prsn_nbr"),
        ),
        (
            "atd_txdot_person",
            "person",
            "people_cris",
            "people_edits",
            "id",
            ("crash_id", "unit_nbr", "prsn_nbr"),
        ),
    ]

    for (
        public_table,
        data_model_table,
        cris_table,
        edits_table,
        id_column,
        unique_identifiers,
    ) in table_sets:
        matching_columns = align_types(
            db_connection_string, public_table, data_model_table
        )
        find_differences(
            db_connection_string,
            public_table,
            data_model_table,
            cris_table,
            edits_table,
            matching_columns,
            id_column,
            unique_identifiers,
        )


def read_json_file(file_path):
    with open(file_path, "r") as json_file:
        data = json.load(json_file)
    return data


def align_types(db_connection_string, public_table, data_model_table):
    with psycopg2.connect(db_connection_string) as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            # Fetch column types from public table
            sql_public = f"""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND table_name   = '{public_table}'
                """
            cur.execute(sql_public)
            public_columns = {row["column_name"]: row["data_type"] for row in cur}

            # Fetch column types from data_model table
            sql_data_model = f"""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_schema = 'data_model' 
                AND table_name   = '{data_model_table}'
                """
            cur.execute(sql_data_model)
            data_model_columns = {row["column_name"]: row["data_type"] for row in cur}

            # Compare column types
            for column, public_type in public_columns.items():
                data_model_type = data_model_columns.get(column)
                if data_model_type is None:
                    print(
                        f"Column {column} does not exist in data_model.{data_model_table}"
                    )
                elif data_model_type != public_type:
                    print(
                        f"Column {column} type mismatch: public.{public_table} - {public_type}, data_model.{data_model_table} - {data_model_type}"
                    )
                    alter = f"ALTER TABLE data_model.{data_model_table} ALTER COLUMN {column} TYPE {public_type} USING NULLIF({column}, '')::{public_type};"
                    cur.execute(alter)
                else:
                    print(f"Column {column} types match: {public_type}")

            # Compare column types
            common_columns = []
            for column, public_type in public_columns.items():
                data_model_type = data_model_columns.get(column)
                if data_model_type is not None:
                    common_columns.append((column, public_type))

            return common_columns


def retrieve_columns(conn, table_name):
    with conn.cursor() as cur:
        cur.execute(
            f"""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name   = '{table_name}'
            """
        )
        return [row[0] for row in cur.fetchall()]


def get_total_records(conn, table_name):
    with conn.cursor() as cur:
        sql = f"SELECT COUNT(*) FROM public.{table_name}"
        cur.execute(sql)
        return cur.fetchone()[0]


def fetch_old_data(conn, table_name):
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(f"SELECT * FROM public.{table_name}")
        rows = cur.fetchall()
        for row in rows:
            # Replace empty strings with None
            for key, value in row.items():
                if value == "":
                    row[key] = None
        return rows


def fetch_corresponding_data(conn, table_name, unique_identifiers):
    data_dict = {}
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(f"SELECT * FROM data_model.{table_name}")
        rows = cur.fetchall()
        for row in rows:
            # Replace empty strings with None
            for key, value in row.items():
                if value == "":
                    row[key] = None
            # Generate a tuple of values for the unique identifiers

            unique_values = tuple(row[id_column] for id_column in unique_identifiers)
            data_dict[unique_values] = row
    return data_dict


def compare_records(
    vz_record, cris_record, matching_columns, edits_columns, public_table
):
    all_column_map = read_json_file("column_map.json")
    column_map = all_column_map[public_table]
    changed_columns_from_spreadsheet = {
        item["old column name"]: item["target column name"]
        for item in column_map
        if item["target column name"] != "-"
        and item["old column name"] != item["target column name"]
    }

    matching_column_names = [item[0] for item in matching_columns]
    matching_column_names.sort(key=lambda x: x[0])  # alphabetical order
    matching_column_names = [  # remove columns that are changed as found in spreadsheet
        item
        for item in matching_column_names
        if item not in changed_columns_from_spreadsheet.values()
    ]

    columns_to_ignore_entirely = ["law_enforcement_num", "movement_id"]

    updates = []

    # handle the columns which change names
    for old_column_name in changed_columns_from_spreadsheet:
        if old_column_name in columns_to_ignore_entirely:
            continue
        if old_column_name in ["latitude_primary", "longitude_primary"]:
            if (
                cris_record[
                    changed_columns_from_spreadsheet[old_column_name]
                ]  # cris record under new column name
                != vz_record[old_column_name]
            ):
                updates.append(
                    (
                        changed_columns_from_spreadsheet[
                            old_column_name
                        ],  # new column name
                        vz_record[old_column_name],
                    )
                )
        elif (
            True
            and vz_record[old_column_name] != cris_record[old_column_name]
            and vz_record[old_column_name]
        ):
            updates.append(
                (
                    changed_columns_from_spreadsheet[
                        old_column_name
                    ],  # new column name
                    vz_record[old_column_name],
                )
            )

    # handle all the pairs of columns where the names match
    for column in matching_column_names:
        if old_column_name in columns_to_ignore_entirely:
            continue
        columns_to_special_handle = [
            "crash_date",
            "crash_time",
            "prsn_death_date",
            "prsn_death_time",
        ]

        if column == "crash_date":
            vz_crash_datetime = datetime.combine(
                vz_record["crash_date"], vz_record["crash_time"]
            )
            cris_crash_datetime = datetime.combine(
                cris_record["crash_date"], cris_record["crash_time"]
            )
            if vz_crash_datetime != cris_crash_datetime:
                updates.append(("crash_time", vz_crash_datetime.isoformat()))
        elif (
            True
            and column == "prsn_death_date"
            and vz_record["prsn_death_date"] is not None
            and vz_record["prsn_death_time"] is not None
            and cris_record["prsn_death_date"] is not None
            and cris_record["prsn_death_time"] is not None
        ):
            vz_death_datetime = datetime.combine(
                vz_record["prsn_death_date"], vz_record["prsn_death_time"]
            )
            cris_death_datetime = datetime.combine(
                cris_record["prsn_death_date"], cris_record["prsn_death_time"]
            )
            if vz_death_datetime != cris_death_datetime:
                updates.append(("prsn_death_date", vz_death_datetime.isoformat()))
                updates.append(("prsn_death_time", vz_death_datetime.isoformat()))
        elif (
            True
            and column not in columns_to_special_handle
            and column in edits_columns
            and vz_record[column] != cris_record[column]
            # prevent a update to set a vz value to null, as they are already null in the edits table
            and not vz_record[column] is None
        ):
            updates.append((column, vz_record[column]))

    # print(updates)
    # print(json.dumps(updates, indent=4))
    # quit()

    return updates


def update_records(
    conn, edits_table, cris_table, updates, unique_identifiers, unique_values
):
    id_column = "id"

    subquery = f"SELECT {id_column} FROM public.{cris_table} WHERE " + " AND ".join(
        (
            f"cris_crash_id = %s"
            if cris_table in ["units_cris", "people_cris"] and id_column == "crash_id"
            else f"{id_column} = %s"
        )
        for id_column in unique_identifiers
    )

    update_sql = (
        f"UPDATE public.{edits_table} SET "
        + ", ".join(f"{column} = %s" for column, _ in updates)
        + f" WHERE {id_column} = ({subquery})"
    )

    params = tuple(value for _, value in updates) + unique_values

    with conn.cursor() as cur:
        try:
            cur.execute(update_sql, params)
            updated_rows = cur.rowcount
            if updated_rows != 1:
                raise Exception()  # we have may have to relax this exception when run in production
        except Exception:
            interpolated_query = cur.mogrify(update_sql, params).decode()
            raise Exception(
                f"Expected to update 1 row, but updated another number of rows.\n"
                f"Query: {interpolated_query}\n"
            )
        conn.commit()


def find_differences(
    db_connection_string,
    public_table,
    data_model_table,
    cris_table,
    edits_table,
    matching_columns,
    id_column,
    unique_identifiers,
):

    with psycopg2.connect(db_connection_string) as conn:
        edits_columns = retrieve_columns(conn, edits_table)

        total_records = get_total_records(conn, public_table)
        print("Total records:", total_records)

        old_vz_data = fetch_old_data(conn, public_table)
        cris_data = fetch_corresponding_data(conn, data_model_table, unique_identifiers)

        with tqdm(
            total=total_records, desc=f"Processing {public_table}"
        ) as progress_bar:
            for vz_record in old_vz_data:
                # Generate a tuple of values for the unique identifiers
                unique_values = tuple(
                    vz_record[id_column] for id_column in unique_identifiers
                )

                cris_record = cris_data.get(unique_values)

                if cris_record is not None:
                    updates = compare_records(
                        vz_record,
                        cris_record,
                        matching_columns,
                        edits_columns,
                        public_table,
                    )
                    if updates:
                        unique_values_str = ", ".join(
                            str(vz_record[id_column])
                            for id_column in unique_identifiers
                        )
                        tqdm.write(
                            f"Record ({unique_values_str}) change count: {len(updates)} "
                        )

                        # this is a nice way to see the changes being written out
                        # updates_dict = dict(updates)
                        # updates_json = json.dumps(updates_dict, indent=4)
                        # tqdm.write(updates_json)

                        update_records(
                            conn,
                            edits_table,
                            cris_table,
                            updates,
                            unique_identifiers,
                            unique_values,
                        )
                progress_bar.update(1)


if __name__ == "__main__":
    main()
