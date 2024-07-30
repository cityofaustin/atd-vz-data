import os
import subprocess

from boto3 import client, resource

from utils.logging import get_logger

from utils.settings import LOCAL_EXTRACTS_DIR

ENV = os.environ["ENV"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
EXTRACT_PASSWORD = os.environ["EXTRACT_PASSWORD"]

logger = get_logger()
s3_client = client("s3")
s3_resource = resource("s3")


def format_megabytes(bytes):
    """Format an integer as megabytes"""
    return f"{round(bytes/1000000)}mb"


def get_extract_name_from_file_name(file_key):
    """Parse the full extract name from the file name"""
    return os.path.basename(file_key).replace(".zip", "")


def get_unzipped_extracts_local():
    """Gets a list of sudirectories in the <LOCAL_EXTRACTS_DIR>, making the assumption that any subdirectory
    is an unzipped CRIS extract.

    Returns a sorted list of dicts as { extract_name, extract_dest_dir }
    """
    unzipped_extracts = []
    for extract_name in os.listdir(LOCAL_EXTRACTS_DIR):
        extract_subdir_full_path = os.path.join(LOCAL_EXTRACTS_DIR, extract_name)
        if os.path.isdir(extract_subdir_full_path):
            unzipped_extracts.append(
                {
                    "s3_file_key": None,
                    "extract_name": extract_name,
                    "extract_dest_dir": extract_subdir_full_path,
                }
            )
    return sorted(unzipped_extracts, key=lambda d: d["extract_name"])


def get_extract_zips_todo_local():
    """Get a list of extract zips in <LOCAL_EXTRACTS_DIR>

    Returns a sorted list of dicts as { s3_file_key, local_zip_file_path, file_size, extract_name }
    """
    extracts = []
    for fname in os.listdir(LOCAL_EXTRACTS_DIR):
        if fname.endswith(".zip"):
            zip_extract_local_path = os.path.join(LOCAL_EXTRACTS_DIR, fname)
            zip_size = os.path.getsize(zip_extract_local_path)
            # we're matching the structure of the dict returned from get_extract_zips_to_download_s3
            extracts.append(
                {
                    "s3_file_key": None,
                    "local_zip_file_path": zip_extract_local_path,
                    "file_size": zip_size,
                    "extract_name": get_extract_name_from_file_name(fname),
                }
            )
    return sorted(extracts, key=lambda d: d["extract_name"])


def get_extract_zips_to_download_s3(subdir="inbox"):
    """Fetch a list of CRIS extract zips that are in `inbox` subdirectory in the S3 bucket.

    Returns a sorted list of dicts as { s3_file_key, local_zip_file_path, file_size, extract_name }
    """
    prefix = f"{ENV}/cris_extracts/{subdir}"
    logger.info(f"Getting list of extracts in {prefix}")
    response = s3_client.list_objects(
        Bucket=BUCKET_NAME,
        Prefix=prefix,
    )
    extracts = []
    for item in response.get("Contents", []):
        key = item.get("Key")
        if key.endswith(".zip"):
            extracts.append(
                {
                    "s3_file_key": key,
                    "local_zip_file_path": os.path.join(
                        LOCAL_EXTRACTS_DIR, os.path.basename(key)
                    ),
                    "file_size": item.get("Size"),
                    "extract_name": get_extract_name_from_file_name(key),
                }
            )

    if not len(extracts):
        raise IOError("No extract zips found in S3 bucket")

    # assumes extract ids are sortable newsest -> oldest
    return sorted(extracts, key=lambda d: d["extract_name"])


def download_extract_from_s3(s3_file_key, file_size, local_zip_file_path):
    """Download zip file from s3 into the provided <local_zip_file_path>"""
    logger.info(f"Downloading {s3_file_key} ({format_megabytes(file_size)})")
    s3_client.download_file(BUCKET_NAME, s3_file_key, local_zip_file_path)


def unzip_extract(local_zip_file_path, out_dir_path):
    """Unzip a cris extract

    Args:
        file_path (str): the full path to the extract zip
        out_dir_path (str): the full path to the directory where extracted files will be saved
    """
    logger.info(f"Unzipping {local_zip_file_path} to {out_dir_path}")
    unzip_command = (
        f'7za -y -p{EXTRACT_PASSWORD} -o{out_dir_path} x "{local_zip_file_path}"'
    )
    subprocess.run(unzip_command, check=True, shell=True, stdout=subprocess.DEVNULL)


def archive_extract_zip(file_key):
    """Move an extract zip from ./inbox to ./archive

    Args:
        s3_client (botocore.client.S3): the s3 client instance
        s3_resource (boto3.resources.factory.s3.ServiceResource): the lower-level S3 "resource" instance
        file_key (str): the s3 object file key of the zip file to be archved
    """
    new_key = file_key.replace("inbox", "archive")
    logger.info(f"Archiving {file_key}")
    s3_resource.meta.client.copy(
        {"Bucket": BUCKET_NAME, "Key": file_key}, BUCKET_NAME, new_key
    )
    s3_client.delete_object(Bucket=BUCKET_NAME, Key=file_key)


def get_extract_dir(extract_name):
    """Construct the full path to an unzipped extract"""
    return os.path.join(LOCAL_EXTRACTS_DIR, extract_name)


def upload_file_to_s3(file_path, object_key):
    s3_client.upload_file(file_path, BUCKET_NAME, object_key)
