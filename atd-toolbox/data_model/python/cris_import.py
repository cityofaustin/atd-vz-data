import csv
from datetime import datetime
import os
import time
from zoneinfo import ZoneInfo

import requests


FILE_DIR = "cris_csvs"
HASURA_ENDPOINT = "http://localhost:8084/v1/graphql"
UPLOAD_BATCH_SIZE = 1000

COLUMN_METADATA_QUERY = """
query ColumnMetadata {
  _column_metadata(where: {is_imported_from_cris: {_eq: true}}) {
    column_name
    record_type
  }
}
"""

CRASH_UPSERT_MUTATION = """
mutation UpsertCrashes($objects: [crashes_cris_insert_input!]!) {
  insert_crashes_cris(
    objects: $objects, 
    on_conflict: {
        constraint: crashes_cris_crash_id_key,
        update_columns: [$updateColumns]
    }) {
    affected_rows
  }
}
"""

UNIT_UPSERT_MUTATION = """
mutation UpsertUnits($objects: [units_cris_insert_input!]!) {
  insert_units_cris(
    objects: $objects, 
    on_conflict: {
        constraint: unique_units_cris,
        update_columns: [$updateColumns]
    }) {
    affected_rows
  }
}
"""

PERSON_UPSERT_MUTATION = """
mutation UpsertPeople($objects: [people_cris_insert_input!]!) {
  insert_people_cris(
    objects: $objects, 
    on_conflict: {
        constraint: unique_people_cris,
        update_columns: [$updateColumns]
    }) {
    affected_rows
  }
}"""

CHARGES_DELETE_MUTATION = """
mutation DeleteCharges($crash_ids: [Int!]!) {
  delete_charges_cris(where: {cris_crash_id: {_in: $crash_ids}}) {
    affected_rows
  }
}
"""

CHARGES_INSERT_MUTATION = """
mutation InsertCharges($objects: [charges_cris_insert_input!]!) {
  insert_charges_cris(objects: $objects) {
    affected_rows
  }
}
"""

mutations = {
    "crashes": CRASH_UPSERT_MUTATION,
    "units": UNIT_UPSERT_MUTATION,
    "persons": PERSON_UPSERT_MUTATION,
    "charges": CHARGES_INSERT_MUTATION,
}

# list of fields to check to determine if a crash victim
# was experiencing homelessness
peh_fields = [
    "drvr_street_nbr",
    "drvr_street_pfx",
    "drvr_street_name",
    "drvr_street_sfx",
    "drvr_apt_nbr",
    "drvr_city_name",
    "drvr_state_id",
    "drvr_zip",
]

# remove when crash_sev_id != 4 (fatal)
name_fields = [
    "prsn_first_name",
    "prsn_mid_name",
    "prsn_last_name",
]


class HasuraAPIError(Exception):
    pass


def get_cris_columns(column_metadata, table_name):
    """
    return an array of strings which is the column names for every column we want to handle from the
    CRIS import and the given table name
    """
    table_key = table_name
    if "person" in table_key:
        table_key = "people"
    return [
        col["column_name"] for col in column_metadata if col["record_type"] == table_key
    ]


def make_upsert_mutation(table_name, cris_columns):
    """Sets the column names in the upsert on conflict array"""
    upsert_mutation = mutations[table_name]
    update_columns = cris_columns.copy()
    return upsert_mutation.replace("$updateColumns", ", ".join(update_columns))


def make_hasura_request(*, query, endpoint, variables=None):
    payload = {"query": query, "variables": variables}
    res = requests.post(endpoint, json=payload)
    res.raise_for_status()
    data = res.json()
    try:
        return data["data"]
    except KeyError as err:
        raise HasuraAPIError(data) from err


def get_file_meta(filename):
    """
    Returns:
        schema_year, extract_id, table_name
    """
    filename_parts = filename.split("_")
    return filename_parts[1], filename_parts[2], filename_parts[3]


def get_files_todo():
    files_todo = []
    for filename in os.listdir(FILE_DIR):
        if not filename.endswith(".csv"):
            continue
        schema_year, extract_id, table_name = get_file_meta(filename)

        # ignore all tables except these
        if table_name not in ("crash", "unit", "person", "primaryperson", "charges"):
            continue

        file = {
            "schema_year": schema_year,
            "table_name": table_name,
            "path": os.path.join(FILE_DIR, filename),
            "extract_id": extract_id,
        }
        files_todo.append(file)
    return files_todo


def load_csv(filename):
    with open(filename, "r") as fin:
        reader = csv.DictReader(fin)
        return [row for row in reader]


def lower_case_keys(list_of_dicts):
    return [{key.lower(): value for key, value in row.items()} for row in list_of_dicts]


def remove_unsupported_columns(rows, cris_columns):
    return [
        {key: val for key, val in row.items() if key in cris_columns} for row in rows
    ]


def handle_empty_strings(rows):
    for row in rows:
        for key, val in row.items():
            if val == "":
                row[key] = None
    return rows


def set_default_values(records, key_values):
    for record in records:
        for key, value in key_values.items():
            record[key] = value


def combine_date_time_fields(
    rows, *, date_field_name, time_field_name, output_field_name, is_am_pm_format
):
    """Combine a date and time field and format as ISO string. The new ISO
    string is stored in the output_field_name.
    """
    tzinfo = ZoneInfo("America/Chicago")
    for row in rows:
        input_date_string = row[date_field_name]
        input_time_string = row[time_field_name]

        if not input_date_string or not input_time_string:
            continue

        # parse a date string that looks like '12/22/2023'
        month, day, year = input_date_string.split("/")

        hour = None
        minute = None
        if is_am_pm_format:
            # parse a time string that looks like '12:15 PM'
            hour_minute, am_pm = input_time_string.split(" ")
            hour, minute = hour_minute.split(":")
            if am_pm.lower() == "pm":
                hour = int(hour) + 12 if hour != "12" else int(hour)
            else:
                hour = int(hour) if hour != "12" else 0
        else:
            # parse a time string that looks like '12:00:00'
            hour, minute, second = input_time_string.split(":")

        # create a tz-aware instance of this datetime

        dt = datetime(
            int(year),
            int(month),
            int(day),
            hour=int(hour),
            minute=int(minute),
            tzinfo=tzinfo,
        )
        # save the ISO string with tz offset
        crash_date_iso = dt.isoformat()
        row[output_field_name] = crash_date_iso


def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


def set_peh_field(record):
    """Determine if a person was experiencing homeless based on
    reportin conventions used by law enforcement crash investigator"""
    for field in peh_fields:
        record_val = record[field]
        for search_term in ["homeless", "unhoused", "transient"]:
            if record_val and search_term in record_val.lower():
                record["prsn_exp_homelessness"] = True
                # no need to continue further
                return


def nullify_name_fields(records):
    for record in records:
        if record["prsn_injry_sev_id"] != "4":
            for field in name_fields:
                record[field] = None
    return


def rename_crash_id(records):
    """rename cris's crash_id column to cris_crash_id"""
    for record in records:
        record["cris_crash_id"] = record.pop("Crash_ID")


def main():
    overall_start_tme = time.time()

    print("Fetching column metadata...")
    column_metadata = make_hasura_request(
        endpoint=HASURA_ENDPOINT, query=COLUMN_METADATA_QUERY
    )["_column_metadata"]

    files_todo = get_files_todo()

    extract_ids = list(set([f["extract_id"] for f in files_todo]))
    # assumes extract ids are sortable oldest > newest by filename. todo: is that right?
    extract_ids.sort()
    for extract_id in extract_ids:
        print(f"processing extract id: {extract_id}")
        # get schema years that match this extract ID
        schema_years = list(
            set([f["schema_year"] for f in files_todo if f["extract_id"] == extract_id])
        )
        schema_years.sort()
        for schema_year in schema_years:
            print(f"processing schema year: {schema_year}")
            for table_name in ["crashes", "units", "persons", "charges"]:
                cris_columns = get_cris_columns(column_metadata, table_name)

                file = next(
                    (
                        f
                        for f in files_todo
                        if f["extract_id"] == extract_id
                        and f["schema_year"] == schema_year
                        and table_name.startswith(f["table_name"])
                    ),
                    None,
                )

                if not file:
                    raise Exception(
                        f"No {table_name} file found in extract. This should never happen!"
                    )

                print(f"processing {table_name}")

                records = load_csv(file["path"])

                # rename Crash_ID to cris_crash_id for all tables except crashes
                if table_name != "crashes":
                    rename_crash_id(records)

                records = lower_case_keys(records)

                if table_name == "crashes":
                    combine_date_time_fields(
                        records,
                        date_field_name="crash_date",
                        time_field_name="crash_time",
                        output_field_name="crash_timestamp",
                        is_am_pm_format=True,
                    )

                # annoying redundant branch to combine primary persons and persons
                if table_name == "persons":

                    p_person_file = next(
                        (
                            f
                            for f in files_todo
                            if f["extract_id"] == extract_id
                            and f["schema_year"] == schema_year
                            and f["table_name"].startswith("primaryperson")
                        ),
                        None,
                    )

                    set_default_values(records, {"is_primary_person": False})
                    pp_records = load_csv(p_person_file["path"])
                    rename_crash_id(pp_records)
                    pp_records = lower_case_keys(pp_records)

                    for record in pp_records:
                        set_peh_field(record)

                    set_default_values(pp_records, {"is_primary_person": True})

                    records = pp_records + records

                    nullify_name_fields(records)

                    combine_date_time_fields(
                        records,
                        date_field_name="prsn_death_date",
                        time_field_name="prsn_death_time",
                        output_field_name="prsn_death_timestamp",
                        is_am_pm_format=False,
                    )

                if table_name == "charges":
                    # set created_by audit field only
                    set_default_values(
                        records,
                        {"created_by": "cris", "cris_schema_version": schema_year},
                    )
                    delete_charges_batch_size = 500
                    crash_ids = list(
                        set([int(record["cris_crash_id"]) for record in records])
                    )
                    print(f"Deleting charges for {len(crash_ids)} total crashes...")
                    for chunk in chunks(crash_ids, delete_charges_batch_size):
                        print(
                            f"deleting charges for {delete_charges_batch_size} crashes..."
                        )
                        make_hasura_request(
                            endpoint=HASURA_ENDPOINT,
                            query=CHARGES_DELETE_MUTATION,
                            variables={"crash_ids": crash_ids},
                        )
                else:
                    # set created_by and updated_by audit fields
                    set_default_values(
                        records,
                        {
                            "created_by": "cris",
                            "updated_by": "cris",
                            "cris_schema_version": schema_year,
                        },
                    )

                records = handle_empty_strings(
                    remove_unsupported_columns(
                        records,
                        cris_columns,
                    )
                )

                upsert_mutation = make_upsert_mutation(table_name, cris_columns)

                for chunk in chunks(records, UPLOAD_BATCH_SIZE):
                    print(f"uploading {len(chunk)} {table_name}...")
                    start_time = time.time()
                    make_hasura_request(
                        endpoint=HASURA_ENDPOINT,
                        query=upsert_mutation,
                        variables={"objects": chunk},
                    )
                    print(f"✅ done in {round(time.time() - start_time, 3)} seconds")

    print(
        f"🎉 Entire import completed in {round((time.time() - overall_start_tme)/60, 2)} minutes"
    )


main()
