"""
Move all zip files in the bucket from ./archive to ./inbox
"""

import os

import boto3


from utils.files import (
    get_extract_zips_to_download_s3,
)

BUCKET_NAME = os.environ["BUCKET_NAME"]
ENV = os.environ["ENV"]


def main():
    s3_resource = boto3.resource("s3")

    extracts = get_extract_zips_to_download_s3(subdir="archive")

    print(f"{len(extracts)} extracts to restore")

    if not extracts:
        return

    ok_to_proceed = input(
        f"About to copy {len(extracts)} extracts into the './inbox' bucket subdirectory in the **{ENV}** environment. Type 'y' to continue: "
    )

    if ok_to_proceed != "y":
        print("aborted")
        return

    for extract in extracts:
        file_key = extract["s3_file_key"]
        new_key = file_key.replace("archive", "inbox")
        print(f"Copying zip to {BUCKET_NAME}/{new_key}")
        s3_resource.meta.client.copy(
            {"Bucket": BUCKET_NAME, "Key": file_key}, BUCKET_NAME, new_key
        )


if __name__ == "__main__":
    main()
