"""Searches the cr3/pdfs subdirectory of the S3 bucket given an environment
(dev, staging, prod), and updates `crashes` records with CR3 metadata
accordingly.

If a CR3 pdf exists in the Bucket but not in the target DB, the update
is ignored"""

import os

from boto3 import client

from utils.graphql import make_hasura_request

ENV = os.environ["ENV"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
EXTRACT_PASSWORD = os.environ["EXTRACT_PASSWORD"]

UPDATE_CRASH_CR3_FIELDS_MANY = """
mutation UpdateCrashCR3FieldsMany($updates: [crashes_cris_updates!]! ) {
    update_crashes_cris_many(updates: $updates) {
        affected_rows
    }
}
"""


def get_crash_id_from_key(key):
    fname = key.split("/")[-1].split(".")[0]
    return int(fname)


def parse_res_data(res_data):
    for row in res_data:
        if row["affected_rows"] > 0:
            print("omg found one")


def main():
    s3_client = client("s3")
    paginator = s3_client.get_paginator("list_objects_v2")
    prefix = f"{ENV}/cr3s/pdfs"

    total_files_found = 0
    # iterate through the all files in the bucket that match our prefix
    for page in paginator.paginate(
        Bucket=BUCKET_NAME,
        Prefix=prefix,
    ):
        updates = []
        if "Contents" in page:
            # extract the crash ID and modified date from each file
            for obj in page["Contents"]:
                cris_crash_id = get_crash_id_from_key(obj["Key"])
                cr3_processed_at = obj["LastModified"].isoformat()
                # build a Hasura 'update many' payload
                row_update = {
                    "where": {"cris_crash_id": {"_eq": cris_crash_id}},
                    "_set": {
                        "cr3_processed_at": cr3_processed_at,
                        "cr3_stored_fl": True,
                    },
                }
                updates.append(row_update)

        total_files_found += len(updates)
        print(f"Updating {len(updates)} crashes. Total will be {total_files_found}")

        res_data = make_hasura_request(
            query=UPDATE_CRASH_CR3_FIELDS_MANY, variables={"updates": updates}
        )["update_crashes_cris_many"]

        parse_res_data(res_data)


if __name__ == "__main__":
    main()
