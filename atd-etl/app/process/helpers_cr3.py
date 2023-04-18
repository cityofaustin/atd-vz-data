"""
Helpers for CR3 Downloads
Author: Austin Transportation Department, Data and Technology Services

Description: This script contains methods that help in the download
and processing of CR3 files, this can include downloading the file
from a CRIS endpoint, uploading files to S3, etc.

The application requires the requests library:
    https://pypi.org/project/requests/
"""

import requests
import base64
import subprocess
import time
from http.cookies import SimpleCookie

import magic

# We need to import our configuration, and the run_query method
from .config import ATD_ETL_CONFIG
from .request import run_query


def wait(int):
    """
    Waits int number of seconds
    :param integer int: The number of seconds to wait
    :return:
    """
    print("Should wait: %s" % str(int))
    time.sleep(int)


def run_command(command):
    """
    Runs a command
    :param command: array of strings containing the command and flags
    """
    print(command)
    print(subprocess.check_output(command, shell=True).decode("utf-8"))


# Now we need to implement our methods.
def download_cr3(crash_id, cookies):
    """
    Downloads a CR3 pdf from the CRIS website.
    :param crash_id: string - The crash id
    :param cookies: dict - A dictionary containing key=value pairs with cookie name and values.
    """

    cookie = SimpleCookie()
    cookie.load(cookies)
    baked_cookies = {}
    for key, morsel in cookie.items():
        baked_cookies[key] = morsel.value

    crash_id_encoded = base64.b64encode(str("CrashId=" + crash_id).encode("utf-8")).decode("utf-8")
    url = ATD_ETL_CONFIG["ATD_CRIS_CR3_URL"] + crash_id_encoded
    download_path = ATD_ETL_CONFIG["AWS_CRIS_CR3_DOWNLOAD_PATH"] + "%s.pdf" % crash_id

    print("Downloading (%s): '%s' from %s" % (crash_id, download_path, url))
    resp = requests.get(url, allow_redirects=True, cookies=baked_cookies)
    open(download_path, 'wb').write(resp.content)

    return download_path

def upload_cr3(crash_id):
    """
    Uploads a file to S3 using the awscli command
    :param crash_id: string - The crash id
    """
    file = "/app/tmp/%s.pdf" % crash_id
    destination = "s3://%s/%s/%s.pdf" % (
        ATD_ETL_CONFIG["AWS_CRIS_CR3_BUCKET_NAME"],
        ATD_ETL_CONFIG["AWS_CRIS_CR3_BUCKET_PATH"],
        crash_id
    )

    run_command("aws s3 cp %s %s --no-progress" % (file, destination))


def delete_cr3s(crash_id):
    """
    Deletes the downloaded CR3 pdf file
    :param crash_id: string - The crash id
    """
    file = "/app/tmp/%s.pdf" % crash_id
    run_command("rm %s" % file)


def get_crash_id_list(downloads_per_run="25"):
    """
    Downloads a list of crashes that do not have a CR3 associated.
    :return: dict - Response from request.post
    """
    query_crashes_cr3 = """
        query CrashesWithoutCR3 {
          atd_txdot_crashes(
            limit: %s,
            where: {
                cr3_stored_flag: {_eq: "N"}
                temp_record: {_eq: false}
            },
            order_by: {crash_date: desc}
          ) {
            crash_id
          }
        }
    """ % (str(downloads_per_run))

    return run_query(query_crashes_cr3)


def update_crash_id(crash_id):
    """
    Updates the status of a crash to having an available CR3 pdf in the S3 bucket.
    :param crash_id: string - The Crash ID that needs to be updated
    :return: dict - Response from request.post
    """

    update_record_cr3 = """
        mutation CrashesUpdateRecordCR3 {
          update_atd_txdot_crashes(where: {crash_id: {_eq: %s}}, _set: {cr3_stored_flag: "Y", updated_by: "System"}) {
            affected_rows
          }
        }
    """ % crash_id
    print(update_record_cr3)
    return run_query(update_record_cr3)

def check_if_pdf(file_path):
    """
    Checks if a file is a pdf
    :param file_path: string - The file path
    :return: boolean - True if the file is a pdf
    """
    mime = magic.Magic(mime=True)
    file_type = mime.from_file(file_path)
    return file_type == "application/pdf"


def process_crash_cr3(crash_record, cookies, skipped_uploads_and_updates):
    """
    Downloads a CR3 pdf, uploads it to s3, updates the database and deletes the pdf.
    :param crash_record: dict - The individual crash record being processed
    :param cookies: dict - The cookies taken from the browser object
    :param skipped_uploads_and_updates: list - Crash IDs of unsuccessful pdf downloads
    """
    try:
        crash_id = str(crash_record["crash_id"])

        print("Processing Crash: " + crash_id)

        download_path = download_cr3(crash_id, cookies)
        is_file_pdf = check_if_pdf(download_path)

        if not is_file_pdf:
            print(f"\nFile {download_path} is not a pdf - skipping upload and update")
            skipped_uploads_and_updates.append(crash_id)
        else:
            upload_cr3(crash_id)
            update_crash_id(crash_id)
            
        delete_cr3s(crash_id)

    except Exception as e:
        print("Error: %s" % str(e))
        return
