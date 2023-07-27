import onepasswordconnectsdk
from onepasswordconnectsdk.client import Client, new_client
from dotenv import load_dotenv
import os
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport

# Load the .env file
load_dotenv()

ONEPASSWORD_CONNECT_TOKEN = os.getenv("OP_API_TOKEN")  # our secret to get secrets 🤐
ONEPASSWORD_CONNECT_HOST = os.getenv("OP_CONNECT")  # where we get our secrets
VAULT_ID = os.getenv("OP_VAULT_ID")

deployment = 'native'

REQUIRED_SECRETS = {
    "graphql-endpoint": {
        "opitem": "Vision Zero graphql-engine Endpoints",
        "opfield": f"{deployment}.GraphQL Endpoint",
        "opvault": VAULT_ID,
        },
    }

client: Client = new_client(ONEPASSWORD_CONNECT_HOST, ONEPASSWORD_CONNECT_TOKEN)
secrets = onepasswordconnectsdk.load_dict(client, REQUIRED_SECRETS)

transport = RequestsHTTPTransport(url=secrets["graphql-endpoint"])
client = Client(transport=transport, fetch_schema_from_transport=True)

query = gql("""
{
    atd_txdot_crashes_aggregate(
    distinct_on: crash_id,
    where: {
            crash_date: {_gte: "2013-07-27", _lte: "2023-07-27"},
            in_austin_full_purpose: {_eq: true},
            private_dr_fl: {_neq: "Y"},
            units: {unit_desc_id: {_eq: 1}},
            _and: [
                {units: {veh_body_styl_id: {_neq: 71}}}, 
                {units: {veh_body_styl_id: {_neq: 90}}}
                ]
            })
    {
    nodes {
        crash_id
        }
    }
}
""")

result = client.execute(query)

#print(result)

unique_crash_ids = {node['crash_id'] for node in result['atd_txdot_crashes_aggregate']['nodes']}

print(unique_crash_ids)