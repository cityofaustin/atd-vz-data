import argparse


def get_cli_args():
    """Create the CLI and parse args

    Returns:
        argparse.Namespace: The CLI namespace
    """
    parser = argparse.ArgumentParser(
        description="Export crash and people records to the Socrata Open Data Portal",
        usage="socrata_export.py",
    )
    parser.add_argument(
        "--people",
        action="store_true",
        help="Only export the people dataset",
    )
    parser.add_argument(
        "--crashes",
        action="store_true",
        help="Only export the crashes",
    )
    return parser.parse_args()
