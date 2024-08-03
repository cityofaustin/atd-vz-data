#!/usr/bin/env python
from utils.cli import get_cli_args
from utils.graphql import create_log_entry, set_log_entry_complete
from utils.logging import init_logger
from utils.process_csvs import process_csvs
from utils.process_pdfs import process_pdfs
from utils.files import (
    get_extract_dir,
    get_unzipped_extracts_local,
    get_extract_zips_todo_local,
    get_extract_zips_to_download_s3,
    download_extract_from_s3,
    unzip_extract,
    archive_extract_zip,
)


def main(cli_args):
    if cli_args.skip_unzip:
        extracts_todo = get_unzipped_extracts_local()
    elif cli_args.s3_download:
        extracts_todo = get_extract_zips_to_download_s3()
    else:
        extracts_todo = get_extract_zips_todo_local()

    logger.info(f"{len(extracts_todo)} extract(s) to process")

    if not extracts_todo:
        return

    for extract in extracts_todo:
        if not cli_args.skip_db:
            log_entry_id = create_log_entry(**extract)
        records_processed = {
            "crashes": 0,
            "units": 0,
            "persons": 0,
            "charges": 0,
            "pdfs": 0,
        }
        log_entry_id = create_log_entry(**extract)
        extract_dir = get_extract_dir(extract["extract_name"])
        if cli_args.s3_download:
            download_extract_from_s3(
                extract["s3_file_key"],
                extract["file_size"],
                extract["local_zip_file_path"],
            )
        if not cli_args.skip_unzip:
            unzip_extract(extract["local_zip_file_path"], extract_dir)
        if cli_args.csv:
            csv_records_processed_dict = process_csvs(extract_dir)
            records_processed.update(csv_records_processed_dict)
        if cli_args.pdf:
            pdfs_processed_count = process_pdfs(
                extract_dir, cli_args.s3_upload, cli_args.workers, cli_args.skip_db
            )
            records_processed["pdfs"] = pdfs_processed_count
        if cli_args.s3_download and cli_args.s3_archive and not cli_args.skip_unzip:
            archive_extract_zip(extract["s3_file_key"])
        if not cli_args.skip_db:
            set_log_entry_complete(
                log_entry_id=log_entry_id, records_processed=records_processed
            )


if __name__ == "__main__":
    cli_args = get_cli_args()
    logger = init_logger(debug=cli_args.verbose)
    if not cli_args.csv and not cli_args.pdf:
        raise ValueError("Must specify at least one of --csv or --pdf")
    if cli_args.s3_archive and not cli_args.s3_download:
        raise ValueError("--s3-archive has no effect without --s3-download")
    if cli_args.skip_unzip and cli_args.s3_download:
        raise ValueError("Cannot use --s3-download in combination with --skip-unzip")
    if cli_args.skip_db and cli_args.csv:
        raise ValueError("skip-db is only meant to be used with PDF processing!")
    main(cli_args)
