from datetime import datetime, timezone
from concurrent.futures import ProcessPoolExecutor
import os
from pathlib import Path

import time

from pdf2image import convert_from_path

from utils.graphql import UPDATE_CRASH_CR3_FIELDS, make_hasura_request
from utils.logging import get_logger
from utils.files import upload_file_to_s3
from utils.settings import (
    DIAGRAM_BBOX_PIXELS,
    NEW_CR3_FORM_TEST_PIXELS,
)

ENV = os.getenv("ENV")
logger = get_logger()


def is_new_cr3_form(page):
    """Determine if the CR3 is following the older or newer format.

    The check is conducted by sampling if various pixels are black.

    Args:
        page (PIL image): the pdf page as an image

    Returns:
        bool: true if the provided page passes the sampling tests
    """
    new_cr3_form = True
    for pixel in NEW_CR3_FORM_TEST_PIXELS:
        rgb_pixel = page.getpixel(pixel)
        if rgb_pixel[0] != 0 or rgb_pixel[1] != 0 or rgb_pixel[2] != 0:
            new_cr3_form = False
            break
    return new_cr3_form


def crop_and_save_diagram(page, crash_id, is_new_cr3_form, extract_dir):
    """Crop out the crash diagram and save it to the local directory.

    The diagram is saved to <extract_dir>/crash_diagrams/<crash_id>.jpeg

    Args:
        page (PIL image): the CR3 pdf page as an image
        crash_id (int): the CRIS crash ID
        is_new_cr3_form (bool): if the CR3 is in the 'new' format
        extract_dir (str): the local directory in which to save the file

    Returns:
        str: diagram_full_path - the full path to the saved diagram, including it's name
        str: diagram_filename - the name of diagram file, .e.g 12345678.jpeg
    """
    bbox = DIAGRAM_BBOX_PIXELS["new"] if is_new_cr3_form else DIAGRAM_BBOX_PIXELS["old"]
    diagram_image = page.crop(bbox)
    diagram_filename = f"{crash_id}.jpeg"
    diagram_full_path = os.path.join(extract_dir, "crash_diagrams", diagram_filename)
    diagram_image.save(diagram_full_path)
    return diagram_full_path, diagram_filename


def get_cr3_object_key(filename, kind):
    """Format the S3 object to which the CR3 PDF or diagram saved"""
    return f"{ENV}/cr3s/{kind}/{filename}"


def process_pdf(extract_dir, filename, s3_upload, index):
    """Handles processing of one CR3 PDF document.

    Args:
        extract_dir (str): the local path to the current extract
        filename (str): the filename of the CR3 PDF process, e.g. 123456.pdf
        s3_upload (bool): if the diagram and PDF should be uploaded to the S3 bucket
        index (int): the index ID of this pdf among all PDFs being processed
    """
    logger.info(f"Processing {filename} ({index})")
    crash_id = int(filename.replace(".pdf", ""))
    pdf_path = os.path.join(extract_dir, "crashReports", filename)
    logger.debug("Converting PDF to image...")
    page = convert_from_path(
        pdf_path,
        fmt="jpeg",  # jpeg is much faster than the default ppm fmt
        first_page=2,  # page 2 has the crash diagram
        last_page=2,
        dpi=150,
    )[0]

    logger.debug("Cropping crash diagram...")
    diagram_full_path, diagram_filename = crop_and_save_diagram(
        page, crash_id, is_new_cr3_form(page), extract_dir
    )

    if s3_upload:
        s3_object_key_pdf = get_cr3_object_key(filename, "pdfs")
        logger.debug(f"Uploading CR3 pdf to {s3_object_key_pdf}")
        upload_file_to_s3(pdf_path, s3_object_key_pdf)

        s3_object_key_diagram = get_cr3_object_key(diagram_filename, "crash_diagrams")
        logger.debug(f"Uploading crash diagram to {s3_object_key_diagram}")
        upload_file_to_s3(diagram_full_path, s3_object_key_diagram)

        logger.debug(f"Updating crash CR3 metadata")
        res = make_hasura_request(
            query=UPDATE_CRASH_CR3_FIELDS,
            variables={
                "crash_id": crash_id,
                "data": {
                    "cr3_processed_at": datetime.now(timezone.utc).isoformat(),
                    "cr3_stored_fl": True,
                },
            },
        )
        # check to make sure that we actually updated a crash record
        affected_rows = res["update_crashes_cris"]["affected_rows"]
        if not affected_rows:
            raise ValueError(
                f"Crash ID: {crash_id} - CR3 PDF has no matching crash record in the DB. This should never happen."
            )


def process_pdfs(extract_dir, s3_upload, max_workers):
    """Main loop for extract crash diagrams from  CR3 PDFs

    Args:
        extract_dir (str): the local path to the current extract
        s3_upload (bool): if the diagram and PDF should be uploaded to the S3 bucket
        max_workers (int): the maximum number of workers to assign to the
            multiprocressing pool
    """
    overall_start_tme = time.time()
    # make the crash_diagram extract directory
    Path(os.path.join(extract_dir, "crash_diagrams")).mkdir(parents=True, exist_ok=True)

    pdfs = [
        filename
        for filename in os.listdir(os.path.join(extract_dir, "crashReports"))
        if filename.endswith(".pdf")
    ]
    pdf_count = len(pdfs)

    if not pdf_count:
        raise IOError("No PDFs found in extract")

    logger.info(f"Found {pdf_count} PDFs to process")

    futures = []
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        for index, filename in enumerate(pdfs):
            future = executor.submit(
                process_pdf, extract_dir, filename, s3_upload, index
            )
            futures.append(future)
    # inspect results and collect all errors—this must be done after all pdfs have
    # processed because future.result() is blocking
    errors = []
    for index, future in enumerate(futures):
        try:
            future.result()
        except Exception as e:
            # grab the filename from the pdf list
            filename = pdfs[index]
            errors.append([filename, e])

    if errors:
        logger.error(
            f"Encountered {len(errors)} error(s) processing PDFs. Logging up to 10 errors and raising the first..."
        )
        for filename, e in errors[0:10]:
            logger.info(f"Error processing {filename}: {e}")
        raise errors[0][1]

    logger.info(
        f"✅ {pdf_count} CR3s processed in {round((time.time() - overall_start_tme)/60, 2)} minutes"
    )
