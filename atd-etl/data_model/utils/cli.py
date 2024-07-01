import argparse


def get_cli_args():
    """Define the CLI parse the current args

    Returns:
        argparse.Namespace: The CLI namespace
    """
    parser = argparse.ArgumentParser(
        description="Process CRIS extact zip files, including CSV data and CR3 crash reports",
        usage="main.py --csv --verbose",
    )
    parser.add_argument(
        f"--csv",
        action="store_true",
        help="Only process CSV files",
    )
    parser.add_argument(
        f"--pdf",
        action="store_true",
        help="Only process CR3 pdfs",
    )
    parser.add_argument(
        f"--s3-download",
        action="store_true",
        help="Source zip extracts from S3 bucket",
    )
    parser.add_argument(
        f"--s3-upload",
        action="store_true",
        help="Upload cr3 pdfs and digrams to S3 bucket",
    )
    parser.add_argument(
        f"--skip-unzip",
        action="store_true",
        help="Only process files that are already unzipped in the local directory",
    )
    parser.add_argument(
        f"--verbose",
        "-v",
        action="store_true",
        help="Sets logging level to DEBUG mode",
    )
    parser.add_argument(
        f"--s3-archive",
        action="store_true",
        help="If using --s3-download, move the processed extracts from the ./inbox to ./archive subdirectory",
    )
    return parser.parse_args()
