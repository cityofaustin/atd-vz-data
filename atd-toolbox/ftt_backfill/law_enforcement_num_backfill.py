"""Backfills fatal crash law enforcement nums from spreadsheet provided by VZ team."""

import argparse
import requests
from datetime import datetime
import pandas as pd

from env import HASURA_AUTH

def read_excel_file():
  df = pd.read_excel('fatalities_list.xlsx', sheet_name="fatality list")
  return df

def make_hasura_request(*, query, variables, env):
  """Fetch data from hasura
  Args:
    query (str): the hasura query
    env (str): the environment name, which will be used to acces secrets
  Raises:
    ValueError: If no data is returned
  Returns:
    dict: Hasura JSON response data
  """
  admin_secret = HASURA_AUTH["hasura_graphql_admin_secret"][env]
  endpoint = HASURA_AUTH["hasura_graphql_endpoint"][env]
  headers = {
    "X-Hasura-Admin-Secret": admin_secret,
    "content-type": "application/json",
  }
  payload = {"query": query, "variables": variables}
  res = requests.post(endpoint, json=payload, headers=headers)
  res.raise_for_status()
  data = res.json()
  try:
    return data["data"]
  except KeyError:
    raise ValueError(data)

CRASHES_UPDATE = """
  mutation UpdateCrash(
    $crash_date: date!,
    $case_id: String!,
    $law_enforcement_num: String!
  ) {
    update_atd_txdot_crashes(
      where: { 
        _and: [
          { crash_date: { _eq: $crash_date }},
          { case_id: { _eq: $case_id }}
        ]
      },
      _set: { law_enforcement_num: $law_enforcement_num }
    ) {
      affected_rows
      returning {
        crash_date
        case_id
        law_enforcement_num
        crash_id
      }
    }
  }
"""


def main(env):
  counts = 0
  df = read_excel_file()

  # Fix types for hasura request
  df['Case ID'] = df['Case ID'].astype(str)
  df['Crash Date'] = df['Crash Date'].dt.strftime('%Y-%m-%d')
  df['APD Fatal Crash'] = df['APD Fatal Crash'].astype(str)
  

  for index, row in df.iterrows():
    # Spreadsheet doesn't have crash id so use case id & date to find correct record
    case_id = row['Case ID']
    crash_date = row['Crash Date']
    # APD Fatal Crash is what will now be called Law Enforcement Number
    law_enforcement_num = row['APD Fatal Crash']
    make_hasura_request(
      query=CRASHES_UPDATE,
      variables={
        "case_id": case_id,
        "crash_date": crash_date,
        "law_enforcement_num": law_enforcement_num
      },
      env=env,
    )
    counts += 1
    print(counts)

  print(counts)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()

  parser.add_argument(
    "-e",
    "--env",
    type=str,
    choices=["local", "staging", "prod"],
    default="staging",
    help=f"Environment",
  )

  args = parser.parse_args()

  main(args.env)