import os
import requests

GRAPHQL_ENDPOINT = os.environ.get("GRAPHQL_ENDPOINT")
GRAPHQL_ENDPOINT_KEY = os.environ.get("GRAPHQL_ENDPOINT_KEY")

# 🙏🏻 https://github.com/cityofaustin/atd-moped/blob/main/moped-toolbox/amd_milestones_backfill/utils.py#L18

def make_hasura_request(*, query, variables={}, endpoint=GRAPHQL_ENDPOINT, admin_secret=GRAPHQL_ENDPOINT_KEY):
    headers = {"X-Hasura-Admin-Secret": admin_secret}
    payload = {"query": query, "variables": variables}
    res = requests.post(endpoint, json=payload, headers=headers)
    res.raise_for_status()
    data = res.json()
    try:
        return data["data"]
    except KeyError:
        raise ValueError(data)
