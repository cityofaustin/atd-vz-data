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



query_original = gql("""
{
atd_txdot_crashes_aggregate(
    where: {
        crash_date: {_gte: "2013-07-28", _lte: "2023-07-28"},
        in_austin_full_purpose: {_eq: true},
        private_dr_fl: {_neq: "Y"},
        _or: [
                {_and: [
                            {units: {unit_desc_id: {_eq: 1}}}, 
                            {_and:  [
                                    {units: {veh_body_styl_id: {_neq: 71}}},
                                    {units: {veh_body_styl_id: {_neq: 90}}}
                                    ]
                            }
                        ]
                }
            ]}
    )
    {
    nodes {
        crash_id
        }
    }

}
""")

query_simplified = gql("""
{
    atd_txdot_crashes_aggregate(
    distinct_on: crash_id,
    where: {
            crash_date: {_gte: "2013-07-28", _lte: "2023-07-28"},
            in_austin_full_purpose: {_eq: true},
            private_dr_fl: {_neq: "Y"},
            units: {unit_desc_id: {_eq: 1}},
            _and: [
                {units: {veh_body_styl_id: {_neq: 71}}}, 
                {units: {veh_body_styl_id: {_neq: 90}}}
                ]
            }
    )
    {
    nodes {
        crash_id
        }
    }
}
""")

query_fixed = gql("""
{
    atd_txdot_crashes_aggregate(
    distinct_on: crash_id,
    where: {
            crash_date: {_gte: "2013-07-28", _lte: "2023-07-28"},
            in_austin_full_purpose: {_eq: true},
            private_dr_fl: {_neq: "Y"},
            units: {
                    unit_desc_id: {_eq: 1}, 
                    veh_body_styl_id: {_nin: [71 90]}
                    }
            }
    )
    {
    nodes {
        crash_id
        }
    }
}
""")

#result = client.execute(query_original)
result = client.execute(query_simplified)
#result = client.execute(query_fixed)

gql_set_crash_ids = set()
for node in result['atd_txdot_crashes_aggregate']['nodes']:
    gql_set_crash_ids.add(node['crash_id'])


cursor = pg.cursor(cursor_factory=RealDictCursor)

cursor.execute("""
select distinct crashes.crash_id
from atd_txdot_crashes crashes
    join atd_txdot_units units on (crashes.crash_id = units.crash_id)
where true 
    and crash_date >= '2013-07-28' and crash_date <= '2023-07-28'
    and crashes.private_dr_fl != 'Y'
    and crashes.in_austin_full_purpose is true
    and units.unit_desc_id = 1
    and units.veh_body_styl_id != 71
    and units.veh_body_styl_id != 90
""")

rows = cursor.fetchall()

sql_set_crash_ids = set()
for row in rows:
    sql_set_crash_ids.add(row['crash_id'])

print("GQL set length: ", len(gql_set_crash_ids))
print("SQL set length: ", len(sql_set_crash_ids))

gql_not_sql = gql_set_crash_ids.difference(sql_set_crash_ids)
sql_not_gql = sql_set_crash_ids.difference(gql_set_crash_ids)

print("GQL not SQL count: ", len(gql_not_sql))
print("SQL not GQL count: ", len(sql_not_gql))

print("GQL not SQL: ", gql_not_sql)
print("SQL not GQL: ", sql_not_gql)
