import onepasswordconnectsdk
from onepasswordconnectsdk.client import Client, new_client
from dotenv import load_dotenv
import os
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport
import psycopg2
from psycopg2.extras import RealDictCursor


# Load the .env file
load_dotenv()

ONEPASSWORD_CONNECT_TOKEN = os.getenv("OP_API_TOKEN")  # our secret to get secrets 🤐
ONEPASSWORD_CONNECT_HOST = os.getenv("OP_CONNECT")  # where we get our secrets
VAULT_ID = os.getenv("OP_VAULT_ID")

RR_USERNAME = os.getenv("VZ_RR_USERNAME")
RR_PASSWORD = os.getenv("VZ_RR_PASSWORD")
RR_HOSTNAME = os.getenv("VZ_RR_HOSTNAME")

GQL_BEARER = os.getenv("GQL_BEARER")

deployment = 'production'

pg = psycopg2.connect(
    dbname="atd_vz_data", 
    user=RR_USERNAME, 
    password=RR_PASSWORD, 
    host=RR_HOSTNAME, 
    port="5432"
)


REQUIRED_SECRETS = {
    "graphql-endpoint": {
        "opitem": "Vision Zero graphql-engine Endpoints",
        "opfield": f"{deployment}.GraphQL Endpoint",
        "opvault": VAULT_ID,
        },
    }

client: Client = new_client(ONEPASSWORD_CONNECT_HOST, ONEPASSWORD_CONNECT_TOKEN)
secrets = onepasswordconnectsdk.load_dict(client, REQUIRED_SECRETS)

headers = {
    'Authorization': f'Bearer {GQL_BEARER}',
    'X-Hasura-Role': 'admin',
}

transport = RequestsHTTPTransport(url=secrets["graphql-endpoint"], headers=headers)
client = Client(transport=transport, fetch_schema_from_transport=True)



query_one = gql("""
{
  atd_txdot_crashes_aggregate(
    where: {
      crash_date: {
        _gte: "2017-08-17",
        _lte: "2023-08-17"
      },
      in_austin_full_purpose: {
        _eq: true
      },
      private_dr_fl: {
        _neq: "Y"
      }
    }
  )    {
    nodes {
        crash_id
        }
    }
}
""")


result = client.execute(query_one)

gql_set_crash_ids_one = set()
for node in result['atd_txdot_crashes_aggregate']['nodes']:
    gql_set_crash_ids_one.add(node['crash_id'])

print("GQL one set length: ", len(gql_set_crash_ids_one))

query_two = gql("""
{
  atd_txdot_crashes_aggregate(
    where: {
      crash_date: {
        _gte: "2017-08-17",
        _lte: "2023-08-17"
      },
      in_austin_full_purpose: {
        _eq: true
      },
      private_dr_fl: {
        _neq: "Y"
      },
      _or: [
        { units: { unit_desc_id: { _eq: 1 }, veh_body_styl_id: { _nin: [71, 90] } } },
        { units: { unit_desc_id: { _eq: 1 }, veh_body_styl_id: { _in: [71, 90] } } },
        { units: { unit_desc_id: { _eq: 3 } } },
        { units: { unit_desc_id: { _eq: 4 } } },
        { units: { unit_desc_id: { _eq: 177 }, veh_body_styl_id: { _eq: 177 } } }
      ]
    }
  )     {
    nodes {
        crash_id
        }
    }
}
""")


result = client.execute(query_two)

gql_set_crash_ids_two = set()
for node in result['atd_txdot_crashes_aggregate']['nodes']:
    gql_set_crash_ids_two.add(node['crash_id'])

print("GQL two set length: ", len(gql_set_crash_ids_two))


print("GQL 1 set length: ", len(gql_set_crash_ids_one))
print("GQL 2 set length: ", len(gql_set_crash_ids_two))

one_not_two = gql_set_crash_ids_one.difference(gql_set_crash_ids_two)
two_not_one = gql_set_crash_ids_two.difference(gql_set_crash_ids_one)

print("one not two count: ", len(one_not_two))
print("two not one count: ", len(two_not_one))

print("one not two: ", one_not_two)
print("two not one: ", two_not_one)


