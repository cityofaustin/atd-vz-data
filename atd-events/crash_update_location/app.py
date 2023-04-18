#
# Resolves the location for a crash.
#
import json
import requests
import time
import os

from typing import Optional

HASURA_ADMIN_SECRET = os.getenv("HASURA_ADMIN_SECRET", "")
HASURA_ENDPOINT = os.getenv("HASURA_ENDPOINT", "")
# The following environment variable should only be set to False for local development.
# In production, this variable should be omitted or set explicitly to true.
HASURA_SSL_VERIFY = os.getenv("HASURA_SSL_VERIFY", True)

# Mechanism to allow setting of a bool via environment variables
if type(HASURA_SSL_VERIFY) == str and HASURA_SSL_VERIFY.lower() in ('false', '0'):
    HASURA_SSL_VERIFY = False

if not HASURA_SSL_VERIFY:
    requests.packages.urllib3.disable_warnings()

# Prep Hasura query
HEADERS = {
    "Content-Type": "application/json",
    "X-Hasura-Admin-Secret": HASURA_ADMIN_SECRET,
}


def raise_critical_error(
        message: str,
        data: dict = None,
        exception_type: object = Exception
):
    """
    Logs an error in Lambda
    :param dict data: The event data
    :param str message: The message to be logged
    :param object exception_type: An optional exception type object
    :return:
    """
    critical_error_message = json.dumps(
        {
            "event_object": data,
            "message": message,
        }
    )
    print(critical_error_message)
    raise exception_type(critical_error_message)


def is_insert(data: dict) -> bool:
    """
    Returns True if the current operation is an insertion, False otherwise.
    :param dict data: The event payload object
    :return bool:
    """
    try:
        return data["event"]["op"] == "INSERT"
    except (TypeError, KeyError):
        raise_critical_error(
            message="No operation description available, data['op'] key not available.",
            data=data,
            exception_type=KeyError
        )

def is_crash_nonproper_and_directional(crash_id: int) -> str:
    """
    Returns location_id of a location based on directionality and rpt_road_part_id for a mainlane crash, Empty string otherwise.
    As a result of the empty string behavior, this can be used as a test as well, to see if a SVRD polygon can be used for a mainlane crash.
    :param int crash_id: The crash_id to be evaluated
    """
    if not str(crash_id).isdigit():
        return False

    check_nonproper_polygon_query = """
    query find_service_road_location($crashId: Int!) {
      find_service_road_location_for_centerline_crash(args: {input_crash_id: $crashId})
      {
        location_id
      }
    }
    """

    try:
        """
            We will attempt to find the record through a query using the find_service_road_location_for_centerline_crash function via Hasura.
            If the location_id key does not contain a location_id, then the crash is not a canidate for being linked to a service road location.
        """
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(
                {
                    "query": check_nonproper_polygon_query,
                    "variables": {
                        "crashId": crash_id
                    }
                }
            ),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )
        if (response.json()["data"]["find_service_road_location_for_centerline_crash"][0]["location_id"] is None):
            return ''
        else:
            return response.json()["data"]["find_service_road_location_for_centerline_crash"][0]["location_id"]
    except:
        """
            In case the response is broken or invalid, we need to:
            - Output the problem for debugging
            - Default to empty string, False by another name, but fitting in the expected str datatype
        """
        return False

def is_crash_mainlane(crash_id: int) -> bool:
    """
    Returns True if the crash is a main-lane, False otherwise.
    :param int crash_id: The crash_id to be evaluated
    :return bool:
    """
    if not str(crash_id).isdigit():
        return False

    check_mainlane_query = """
        query findMainLaneCrashCR3($crash_id: Int!) {
          find_cr3_mainlane_crash(args: {
            cr3_crash_id: $crash_id
          }){
            crash_id
          }
        }
    """


    try:
        """
            We will attempt to find the record through the find_cr3_mainlane_crash function,
            if no matches are returned, then it means the crash is not a main-lane.
        """
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(
                {
                    "query": check_mainlane_query,
                    "variables": {
                        "crash_id": crash_id
                    }
                }
            ),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )
        return len(response.json()["data"]["find_cr3_mainlane_crash"]) > 0
    except Exception as e:
        """
            In case the response is broken or invalid, we need to:
            - Output the problem for debugging
            - Default to False, let it be part of a location for now.
        """
        print(str(e))
        return False


def get_crash_id(data: dict) -> int:
    """
    Attempts to retrieve the crash_id from a data dictionary
    :param dict data: The event data
    :return int: An int containing the crash_id
    """
    try:
        return data["event"]["data"]["new"]["crash_id"]
    except (TypeError, KeyError):
        raise_critical_error(
            message="Unable to parse request body to identify a crash_id",
            data=data
        )


def get_location_id(data: dict) -> Optional[str]:
    """
    Returns location_id from a data dictionary, or defaults to None
    :param dict data: The event data
    :return str|None: A string containing the location id, or None
    """
    try:
        return data["event"]["data"]["new"]["location_id"]
    except (TypeError, KeyError):
        return None


def find_crash_location(crash_id: int) -> Optional[str]:
    """
    Attempts to find the crash_id of the record to be evaluated.
    :param int crash_id: The crash_id to be evaluated
    :return str: The location_id string
    """
    if not str(crash_id).isdigit():
        return None

    find_location_query = """
        query getLocationAssociation($crash_id: Int!) {
            find_location_for_cr3_collision(args: {id: $crash_id}){
                location_id
            }
        }
    """


    try:
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(
                {
                    "query": find_location_query,
                    "variables": {
                        "crash_id": crash_id
                    }
                }
            ),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )
        return response.json()["data"]["find_location_for_cr3_collision"][0]["location_id"]
    except:
        return None


def load_data(record: str) -> dict:
    """
    Attempts to parse the event data
    :param str record: The event data as string
    :return dict: The event data as an object
    """
    try:
        return json.loads(record)
    except (TypeError, json.decoder.JSONDecodeError) as e:
        raise_critical_error(
            message=f"Unable to parse event data payload: {str(e)}",
            data={"record": record},
            exception_type=TypeError
        )


def get_cr3_location_id(crash_id: int) -> Optional[str]:
    """
    Runs a graphql query and returns the current location_id for a CR3 crash record.
    :param int crash_id: The crash_id in question
    :return str|None: The current location_id
    """
    if not str(crash_id).isdigit():
        return None

    query_get_location_id = {
        "query": """
            query getCrashLocationId($crashId:Int!) {
              atd_txdot_crashes(where: {crash_id: {_eq: $crashId}}){
                location_id
              }
            }
        """,
        "variables": {
            "crashId": crash_id
        }
    }
    try:
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(query_get_location_id),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )
        return response.json()["data"]["atd_txdot_crashes"][0]["location_id"]
    except (IndexError, KeyError, TypeError):
        return None


def update_location(crash_id: int, new_location_id: str) -> dict:
    """
    Returns a dictionary and HTTP response from the GraphQL query
    :param int crash_id: The crash_id of the record to be updated
    :param new_location_id: The new location id for the record
    :return dict:
    """
    if crash_id is None:
        raise_critical_error(
            message=f"No crash_id provided to update the location",
        )
    # Output
    mutation_response = {}
    # Prepare the query body
    mutation_json_body = {
        "query": """
            mutation updateCrashLocationID($crashId: Int!, $locationId: String) {
                update_atd_txdot_crashes(where: {crash_id: {_eq: $crashId}}, _set: {location_id: $locationId}) {
                    affected_rows
                }
            }
        """,
        "variables": {
            "crashId": crash_id,
            "locationId": new_location_id
        },
    }
    # Execute the mutation
    try:
        mutation_response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(mutation_json_body),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )
    except Exception as e:
        raise_critical_error(
            message=f"Unable to update crash_id location: {str(e)}"
        )

    return {
        "status": "Mutation Successful",
        "response": mutation_response.json()
    }

def get_centroid_for_location(location_id: str) -> list:
    """
    Returns a array of the longitude and latitude for a given location.

    :param location_id: The location_id to be queried
    :return list:
    """

    centroid_query = {
        "query": """
        query get_centroid($locationId: String) {
          atd_txdot_locations_with_centroids(where: {location_id: {_eq: $locationId}}) {
            centroid
            }
          }
        """,
        "variables": {
            "locationId": location_id
        }}

    try:
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(centroid_query),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )

        return response.json()["data"]["atd_txdot_locations_with_centroids"][0]["centroid"]["coordinates"]
    except (IndexError, KeyError, TypeError):
        return None


def set_crash_position(crashId: int, point: list) -> int:
    """
    Update a crashes latitude_primary and longitude_primary field and return boolean indicating success of failure.

    :param crashId: The ID of the crash to move
    :param point: A list containing the X, Y float values representing the longitude and latitude of a location.
    :return int:
    """

    mutation = {
        "query": """
            mutation update_crash_position($crashId: Int!, $longitude: float8, $latitude: float8) {
                update_atd_txdot_crashes(where: {crash_id: {_eq: $crashId}},
                _set:{latitude_primary:$latitude, longitude_primary: $longitude}) {
                    affected_rows
                }
            }
        """,
        "variables": {
            "crashId": crashId,
            "longitude": point[0],
            "latitude": point[1]
            }
        }

    try:
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(mutation),
            headers=HEADERS,
            verify=HASURA_SSL_VERIFY
        )

        return response.json()["data"]["atd_txdot_locations_with_centroids"][0]["centroid"]["coordinates"]
    except (IndexError, KeyError, TypeError):
        return None




def hasura_request(record: str) -> bool:
    """
    Returns True if the record was processed, False if no need for update.
    :param str record: The json payload from Hasura
    :returns bool:
    """
    # Get data/crash_id from Hasura Event request
    data = load_data(record=record)

    # Try getting the crash data
    crash_id = get_crash_id(data)
    old_location_id = get_location_id(data)
    relocate_crash_to_service_road_centroid = False

    # Check if this crash is a main-lane
    if is_crash_mainlane(crash_id):
        if(nonproper_level_5_directional_polygon := is_crash_nonproper_and_directional(crash_id)):
            new_location_id = nonproper_level_5_directional_polygon
            relocate_crash_to_service_road_centroid = True
            centroid = get_centroid_for_location(new_location_id)
            set_crash_position(crash_id, centroid)
        else:
            # If so, make sure to nullify the new location_id
            new_location_id = None
    else:
        # If not, then try to find the location...
        new_location_id = find_crash_location(crash_id)


    # Now compare the location values:
    if new_location_id == old_location_id:
        # No need to update
        return False

    # There is an update to the location
    else:
        update_location(
            crash_id=crash_id,
            new_location_id=new_location_id
        )
        return True


def handler(event, context):
    """
    Event handler main loop. It handles a single or multiple SQS messages.
    :param dict event: One or many SQS messages
    :param dict context: Event context
    """

    if event and "Records" in event:
        for record in event["Records"]:
            time_str = time.ctime()
            if "body" in record:
                try:
                    hasura_request(record["body"])
                except Exception as e:
                    print(f"Start Time: {time_str}", str(e))
                    time_str = time.ctime()
                    print("Done executing: ", time_str)
                    raise_critical_error(
                        message=f"Could not process record: {str(e)}",
                        data=record,
                        exception_type=Exception
                    )



# Mechanism to test easily on the command line

#if __name__ == "__main__":
    #event = {'Records': [{'body': """ { "event": { "data": { "old": null, "new": {
                #"crash_id": 18267534,
              #"location_id": null } } } } """}]}
    #context = {}
    #handler(event, context)
