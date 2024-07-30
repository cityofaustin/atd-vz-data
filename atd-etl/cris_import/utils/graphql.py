from datetime import datetime, timezone
import os

import requests

from utils.exceptions import HasuraAPIError

ENDPOINT = os.getenv("HASURA_GRAPHQL_ENDPOINT")
ADMIN_SECRET = os.getenv("HASURA_GRAPHQL_ADMIN_SECRET")

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

CRIS_IMPORT_LOG_INSERT_MUTATION = """
mutation InsertImportLog($data: cris_import_log_insert_input!) {
  insert_cris_import_log_one(object: $data) {
    id
  }
}
"""

CRIS_IMPORT_LOG_UPDATE_MUTATION = """
mutation UpdateImportLog($data: cris_import_log_set_input!, $id: Int!) {
  update_cris_import_log_by_pk(pk_columns: {id: $id}, _set: $data) {
    id
  }
}
"""

UPDATE_CRASH_CR3_FIELDS = """
mutation UpdateCrashCR3Fields($crash_id: Int!, $data: crashes_cris_set_input!) {
    update_crashes_cris(where: { crash_id: { _eq: $crash_id } }, _set: $data) {
        affected_rows
        returning {
        id
        }
    }
}
"""

UPSERT_RECORD_MUTATIONS = {
    "crashes": CRASH_UPSERT_MUTATION,
    "units": UNIT_UPSERT_MUTATION,
    "persons": PERSON_UPSERT_MUTATION,
    "charges": CHARGES_INSERT_MUTATION,
}


def make_hasura_request(*, query, variables=None):
    """Make a POST request to the graphql API.

    Requires HASURA_GRAPHQL_ENDPOINT env var.

    Args:
        query (str): the graphql query
        variables (dict, optional): the query variables. Defaults to None.
    Raises:
        HasuraAPIError: If the API response JSON does not contain a top-level `data`
            property
    Returns:
        dict: The `data` property of the JSON response
    """
    if not ENDPOINT:
        raise OSError("HASURA_GRAPHQL_ENDPOINT env var is missing/None")
    payload = {"query": query, "variables": variables}
    res = requests.post(
        ENDPOINT, json=payload, headers={"x-hasura-admin-secret": ADMIN_SECRET}
    )
    res.raise_for_status()
    data = res.json()
    try:
        return data["data"]
    except (KeyError, TypeError) as err:
        raise HasuraAPIError(data) from err


def create_log_entry(
    *, s3_file_key=None, extract_name=None, local_zip_file_path=None, **kwargs
):
    """Insert a new entry in the `cris_import_log` tracking table.

    Args:
        s3_file_key (str, optional): the S3 file key of the extract. Defaults to None.
        extract_name (str, optional): the name of the extract. required if s3_file_key is None.

    Returns:
        int: the record ID of the log entry that was created
    """
    if not s3_file_key and not extract_name:
        raise ValueError("s3_file_key or extract_name are required to create log entry")

    object_name = (
        s3_file_key
        if s3_file_key
        else local_zip_file_path if local_zip_file_path else extract_name
    )

    variables = {
        "data": {
            "object_path": s3_file_key if s3_file_key else "local",
            "object_name": object_name,
        }
    }
    data = make_hasura_request(
        query=CRIS_IMPORT_LOG_INSERT_MUTATION, variables=variables
    )
    return data["insert_cris_import_log_one"]["id"]


def set_log_entry_complete(*, log_entry_id):
    """Set the completed_at timestamp of a cris_activity_log record

    Args:
        log_entry_id (int): the log record ID
    """
    variables = {
        "id": log_entry_id,
        "data": {"completed_at": datetime.now(timezone.utc).isoformat()},
    }
    make_hasura_request(query=CRIS_IMPORT_LOG_UPDATE_MUTATION, variables=variables)
    return
