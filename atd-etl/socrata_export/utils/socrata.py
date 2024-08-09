import os

from sodapy import Socrata

SOCRATA_APP_TOKEN = os.getenv("SOCRATA_APP_TOKEN")
SOCRATA_KEY_ID = os.getenv("SOCRATA_KEY_ID")
SOCRATA_KEY_SECRET = os.getenv("SOCRATA_KEY_SECRET")


def get_socrata_client():
    return Socrata(
        "datahub.austintexas.gov",
        SOCRATA_APP_TOKEN,
        username=SOCRATA_KEY_ID,
        password=SOCRATA_KEY_SECRET,
        timeout=30,
    )
