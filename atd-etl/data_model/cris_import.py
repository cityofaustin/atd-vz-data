#!/usr/bin/env python
from utils.cli import get_cli_args
from utils.graphql import create_log_entry, set_log_entry_complete
from utils.logging import init_logger
from utils.process_csvs import process_csvs
from utils.process_pdfs import process_pdfs
from utils.files import (
    get_unzipped_extracts_local,
    get_extract_zips_todo_local,
    get_extract_zips_to_download_s3,
    download_and_unzip_extract_if_needed,
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
        log_entry_id = create_log_entry(**extract)
        extract_dir = download_and_unzip_extract_if_needed(
            cli_args.s3_download, cli_args.skip_unzip, extract
        )
        if cli_args.csv or (not cli_args.pdf and not cli_args.csv):
            process_csvs(extract_dir)
        if cli_args.pdf or (not cli_args.pdf and not cli_args.csv):
            process_pdfs(extract_dir, cli_args.s3_upload)
        if cli_args.s3_download and cli_args.s3_archive and not cli_args.skip_unzip:
            archive_extract_zip(extract["s3_file_key"])
        set_log_entry_complete(log_entry_id=log_entry_id)


if __name__ == "__main__":
    cli_args = get_cli_args()
    logger = init_logger(debug=cli_args.verbose)
    if cli_args.s3_archive and not cli_args.s3_download:
        raise ValueError("--s3-archive has no effect without --s3-download")
    if cli_args.skip_unzip and cli_args.s3_download:
        raise ValueError("Cannot use --s3-download in combination with --skip-unzip")
    main(cli_args)
