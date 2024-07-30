import csv
from datetime import datetime
import os
import time
from zoneinfo import ZoneInfo

from utils.graphql import (
    make_hasura_request,
    UPSERT_RECORD_MUTATIONS,
    COLUMN_METADATA_QUERY,
    CHARGES_DELETE_MUTATION,
)
from utils.logging import get_logger
from utils.settings import CSV_UPLOAD_BATCH_SIZE

logger = get_logger()


"""list of fields to check when setting the prsn_exp_homelessness flag"""
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

"""list of fields which contain people's names - these fields will be nullified
except in cases of fatal injury"""
name_fields = [
    "prsn_first_name",
    "prsn_mid_name",
    "prsn_last_name",
]


def get_cris_columns(column_metadata, table_name):
    """Get the list of column names for every column we want to handle in the CRIS csv.

    Args:
        column_metadata (list): A list of dicts from the `_column_metadata` DB table, each with
         a `column_name` and `record_type` attribute
        table_name (str): the name of the CRIS table/record type to handle

    Returns:
        list: a list of of column name strings
    """
    table_key = table_name
    if "person" in table_key:
        table_key = "people"
    return [
        col["column_name"] for col in column_metadata if col["record_type"] == table_key
    ]


def make_upsert_mutation(table_name, cris_columns):
    """Retrieves the graphql query string for a record mutation

    Args:
        table_name (str): `crashes`, `units`, `charges`, or `people`
        cris_columns (list): a list of column names that should be updated if a given
        record already exists. Essentially this is a list of all columns except the
            table's primary key. It enables upserting.
            See: https://hasura.io/docs/latest/mutations/postgres/upsert/

    Returns:
        str: the graphql query string
    """
    upsert_mutation = UPSERT_RECORD_MUTATIONS[table_name]
    update_columns = cris_columns.copy()
    return upsert_mutation.replace("$updateColumns", ", ".join(update_columns))


def get_file_meta(filename):
    """Parse file metadata out of the CRIS CSV filename.

    If CRIS changes this naming convention it causes headaches.

    Returns:
         list: [<schema_year:str>, <extract_id:str>, <table_name:str>]
            - schema_year: the CRIS schema year of the records
            - table_name: the record type (crash, unit, person, priamryperson, charges)
            - extract_id: the unique extract ID of the file
    """
    filename_parts = filename.split("_")
    return filename_parts[1], filename_parts[2], filename_parts[3]


def get_csvs_todo(extract_dir):
    """Construct a list of CSV file metadata for each CSV in the given directory

    Args:
        extract_dir (str): The full path to the directory which contains the CSV files

    Raises:
        ValueError: If an unsupported CRIS schema version is detected

    Returns:
        list: A list of dicts where entry contains important file metadata:
            - schema_year: the CRIS schema year of the records
            - table_name: the record type (crash, unit, person, priamryperson, charges)
            - path: the full path to the CSV
            - extract_id: the unique extract ID of the file
    """
    csvs_todo = []
    for filename in os.listdir(extract_dir):
        if not filename.endswith(".csv"):
            continue
        schema_year, extract_id, table_name = get_file_meta(filename)

        # ignore all tables except these
        if table_name not in ("crash", "unit", "person", "primaryperson", "charges"):
            continue

        if not int(schema_year) > 2000 or not int(schema_year) < 2024:
            raise ValueError(f"Unexpected CRIS schema year provided: {schema_year}")

        file = {
            "schema_year": schema_year,
            "table_name": table_name,
            "path": os.path.join(extract_dir, filename),
            "extract_id": extract_id,
        }
        csvs_todo.append(file)
    return csvs_todo


def load_csv(filename):
    """Read a CSV file into a list of dicts"""
    with open(filename, "r") as fin:
        reader = csv.DictReader(fin)
        return [row for row in reader]


def lower_case_keys(records):
    """Copy a list of record dicts by making each key lower case"""
    return [{key.lower(): value for key, value in record.items()} for record in records]


def remove_unsupported_columns(records, columns_to_keep):
    """Copy a list of dicts by excluding all attributes not defined in <columns_to_keep>"""
    return [
        {key: val for key, val in record.items() if key in columns_to_keep}
        for record in records
    ]


def set_empty_strings_to_none(records):
    """Traverse every record property and set '' to None"""
    for record in records:
        for key, val in record.items():
            if val == "":
                record[key] = None
    return records


def set_default_values(records, key_values):
    """Assign default values to a list of dicts

    Args:
        records (list): list of record dicts
        key_values (dict): a dict of keys with their default values in the form of { <key>: <value> }

    Returns:
        None: records are updated in place
    """
    for record in records:
        for key, value in key_values.items():
            record[key] = value


def combine_date_time_fields(
    records,
    *,
    date_field_name,
    time_field_name,
    output_field_name,
    is_am_pm_format,
    tz="America/Chicago",
):
    """Combine a date and time field and format as ISO string. The new ISO
    string is stored in the output_field_name.

    Args:
        record (list): list of CRIS record dicts
        date_field_name (str): the name of the attribute which holds the date value
        time_field_name (str): the name of the attribute which holds the time value
        output_field_name (str): the name of attribute to which the date-time will be assigned
        is_am_pm_format (bool): indictates which flavor of timestamp is provided. if true,
            the input format is expected to match, e.g. '12:15 PM', otherwise a 24hr clock
            is expected. We are handling quirky formatting in the CRIS extract data.
        tz (string): The IANA time zone name of the input time value. Defaluts to America/Chicago

    Returns:
        None: records are updated in-place
    """
    tzinfo = ZoneInfo(tz)
    for record in records:
        input_date_string = record[date_field_name]
        input_time_string = record[time_field_name]

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
        record[output_field_name] = crash_date_iso


def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


def set_peh_field(record):
    """Assign the `prsn_exp_homelessness` flag based on reporting conventions used by
    law enforcement crash investigators"""
    for field in peh_fields:
        record_val = record[field]
        for search_term in ["homeless", "unhoused", "transient"]:
            if record_val and search_term in record_val.lower():
                record["prsn_exp_homelessness"] = True
                # no need to continue further
                return


def nullify_name_fields(records):
    """Assigns `None` to all name fields where prsn_injry_sev_id is not 4 (fatality)"""
    for record in records:
        if record["prsn_injry_sev_id"] != "4":
            for field in name_fields:
                record[field] = None


def rename_crash_id(records):
    """Rename CRIS's `crash_id` column to `cris_crash_id`. Records are modified in-place.

    This is necessary for all record types except crashes, because the `crash_id`
    column on these tables references the `crash.id` custom ID column.
    """
    for record in records:
        record["cris_crash_id"] = record.pop("Crash_ID")


def remove_non_charges(records):
    """Remove charges records where the charge = 'NO CHARGES'. we don't use this data, and
    because it's quite a lot of data we elect to exclude t from the DB entirely"""
    return [r for r in records if r["charge"] != "NO CHARGES"]


def process_csvs(extract_dir):
    """Main function for loading CRIS CSVs into the database. This function handles
    one unzipped CRIS extract, which itself may contain multiple schema years.

    Args:
        extract_dir (str): The full path to the directory which contains the
            unzipped CSV files to be processed

    Returns:
        None
    """
    total_crash_count = 0
    overall_start_tme = time.time()

    logger.debug("Fetching column metadata")
    column_metadata = make_hasura_request(query=COLUMN_METADATA_QUERY)[
        "_column_metadata"
    ]

    csvs_to_import = get_csvs_todo(extract_dir)

    extract_ids = list(set([f["extract_id"] for f in csvs_to_import]))
    # assumes extract ids are sortable oldest > newest by filename. todo: is that right?
    extract_ids.sort()
    for extract_id in extract_ids:
        logger.info(f"Processing CSVs for extract ID: {extract_id}")
        # get schema years that match this extract ID
        schema_years = list(
            set(
                [
                    f["schema_year"]
                    for f in csvs_to_import
                    if f["extract_id"] == extract_id
                ]
            )
        )
        schema_years.sort()
        for schema_year in schema_years:
            logger.debug(f"Processing schema year: {schema_year}")
            for table_name in ["crashes", "units", "persons", "charges"]:
                cris_columns = get_cris_columns(column_metadata, table_name)

                file = next(
                    (
                        f
                        for f in csvs_to_import
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

                logger.debug(f"processing {table_name}")

                records = load_csv(file["path"])

                # rename Crash_ID to cris_crash_id for all tables except crashes
                if table_name != "crashes":
                    rename_crash_id(records)

                records = lower_case_keys(records)

                if table_name == "crashes":
                    total_crash_count += len(records)
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
                            for f in csvs_to_import
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
                    logger.debug(
                        f"Deleting charges in batches for {len(crash_ids)} total crashes"
                    )
                    for chunk in chunks(crash_ids, delete_charges_batch_size):
                        logger.debug(f"Deleting {delete_charges_batch_size} crashes")
                        make_hasura_request(
                            query=CHARGES_DELETE_MUTATION,
                            variables={"crash_ids": crash_ids},
                        )
                    # now that we've deleted all charges we can purge the non-charge records
                    # from our import
                    records = remove_non_charges(records)
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

                records = remove_unsupported_columns(
                    records,
                    cris_columns + ["created_by", "updated_by"],
                )

                records = set_empty_strings_to_none(records)

                upsert_mutation = make_upsert_mutation(table_name, cris_columns)

                for chunk in chunks(records, CSV_UPLOAD_BATCH_SIZE):
                    logger.info(f"Uploading {len(chunk)} {table_name}")
                    start_time = time.time()
                    make_hasura_request(
                        query=upsert_mutation,
                        variables={"objects": chunk},
                    )
                    logger.debug(
                        f"✅ done in {round(time.time() - start_time, 3)} seconds"
                    )

    logger.info(
        f"✅ {total_crash_count} crashes imported in {round((time.time() - overall_start_tme)/60, 2)} minutes"
    )
