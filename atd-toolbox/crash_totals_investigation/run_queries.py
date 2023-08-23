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

query = gql("""
{
  view_fatalities(
    where: {
      crash_date: {
        _gte: "2014-07-28",
        _lte: "2023-07-28"
      },
      _or: [
        {
          person: {
            unit: {
              unit_desc_id: {
                _eq: 1
              },
              veh_body_styl_id: {
                _nin: [71, 90]
              }
            }
          }
        },
        {
          primaryperson: {
            unit: {
              unit_desc_id: {
                _eq: 1
              },
              veh_body_styl_id: {
                _nin: [71, 90]
              }
            }
          }
        }
      ]
    }
  ) {
    crash_id
    ytd_fatal_crash
    ytd_fatality
    crash_date
  }
}
""")



result = client.execute(query)

gql_set_crash_ids = set()
for node in result['view_fatalities']:
    gql_set_crash_ids.add(node['crash_id'])


cursor = pg.cursor(cursor_factory=RealDictCursor)

cursor.execute("""
with all_people as (
select person.prsn_nbr, 
  person.crash_id, 
  person.unit_nbr, 
  person.prsn_injry_sev_id,
  'nonprimary' as class 
from atd_txdot_person person
where person.prsn_injry_sev_id = 4
union
select primaryperson.prsn_nbr, 
  primaryperson.crash_id, 
  primaryperson.unit_nbr, 
  primaryperson.prsn_injry_sev_id, 
  'primary' as class 
from atd_txdot_primaryperson primaryperson
where primaryperson.prsn_injry_sev_id = 4
)
select crashes.crash_id, units.unit_nbr, people.prsn_nbr, people.prsn_injry_sev_id
--select count(distinct(crashes.crash_id))
from atd_txdot_crashes crashes
  left join atd_txdot_units units on (crashes.crash_id = units.crash_id)
  left join all_people people on 
    (people.crash_id = crashes.crash_id 
    and people.unit_nbr = units.unit_nbr)
where true
  and crashes.crash_date >= '2014-07-28' 
  and crashes.crash_date <= '2023-07-28'
  and units.unit_desc_id  = 1
  and units.veh_body_styl_id not in (71,90)
  and people.prsn_injry_sev_id = 4
  and crashes.in_austin_full_purpose is true
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
