import argparse

from utils.settings import MULTIPROCESSING_PDF_MAX_WORKERS


def get_cli_args():
    """Create the CLI and parse args

    Returns:
        argparse.Namespace: The CLI namespace
    """
    parser = argparse.ArgumentParser(
        description="Process CRIS extact zip files, including CSV data and CR3 crash reports",
        usage="main.py --csv --verbose",
    )
    parser.add_argument(
        "--csv",
        action="store_true",
        help="Process CSV files. At least one of --csv or --pdf is required",
    )
    parser.add_argument(
        "--pdf",
        action="store_true",
        help="Process CR3 pdfs. At least one of --csv or --pdf is required",
    )
    parser.add_argument(
        "--s3-download",
        action="store_true",
        help="Source zip extracts from S3 bucket",
    )
    parser.add_argument(
        "--s3-upload",
        action="store_true",
        help="Upload cr3 pdfs and digrams to S3 bucket",
    )
    parser.add_argument(
        "--s3-archive",
        action="store_true",
        help="If using --s3-download, move the processed extracts from the ./inbox to ./archive subdirectory",
    )
    parser.add_argument(
        "--skip-unzip",
        action="store_true",
        help="Only process files that are already unzipped in the local directory",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Sets logging level to DEBUG mode",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=MULTIPROCESSING_PDF_MAX_WORKERS,
        help=f"The number of concurrent workers to use when processing PDFs. Default {MULTIPROCESSING_PDF_MAX_WORKERS}.",
    )
    return parser.parse_args()
