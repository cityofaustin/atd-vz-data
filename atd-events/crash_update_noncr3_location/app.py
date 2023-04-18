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


def is_crash_mainlane(case_id: int) -> bool:
    """
    Returns True if the crash is a main-lane, False otherwise.
    :param int case_id: The case_id to be evaluated
    :return bool:
    """
    if not str(case_id).isdigit():
        return False

    check_mainlane_query = """
        query findMainLaneCrashNonCR3($caseId: Int!) {
            find_noncr3_mainlane_crash(args: {
                ncr3_case_id: $caseId
            }){
                case_id
            }
        }
    """


    try:
        """
            We will attempt to find the record through the find_noncr3_mainlane_crash function,
            if no matches are returned, then it means the crash is not a main-lane.
        """
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(
                {
                    "query": check_mainlane_query,
                    "variables": {
                        "caseId": case_id
                    }
                }
            ),
            headers=HEADERS
        )
        return len(response.json()["data"]["find_noncr3_mainlane_crash"]) > 0
    except:
        """
            In case the response is broken or invalid, we need to:
            - Output the problem for debugging
            - Default to False, let it be part of a location for now.
        """
        return False


def get_case_id(data: dict) -> int:
    """
    Attempts to retrieve the case_id from a data dictionary
    :param dict data: The event data
    :return int: An int containing the case_id
    """
    try:
        return data["event"]["data"]["new"]["case_id"]
    except (TypeError, KeyError):
        raise_critical_error(
            message="Unable to parse request body to identify a case_id",
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


def find_crash_location(case_id: int) -> Optional[str]:
    """
    Attempts to find the case_id of the record to be evaluated.
    :param int case_id: The case_id to be evaluated
    :return str: The location_id string
    """
    if not str(case_id).isdigit():
        return None

    find_location_query = """
        query getLocationForNonCR3($caseId:Int) {
            find_location_for_noncr3_collision(args: {id: $caseId}){
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
                        "caseId": case_id
                    }
                }
            ),
            headers=HEADERS
        )
        return response.json()["data"]["find_location_for_noncr3_collision"][0]["location_id"]
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


def get_noncr3_location_id(case_id: int) -> Optional[str]:
    """
    Runs a graphql query and returns the current location_id for a CR3 crash record.
    :param int case_id: The case_id in question
    :return str|None: The current location_id
    """
    if not str(case_id).isdigit():
        return None

    query_get_location_id = {
        "query": """
          query getNonCR3CrashLocationId($caseId:Int!) {
            atd_apd_blueform(where: {case_id: {_eq: $caseId}}){
              location_id
            }
          }
        """,
        "variables": {
            "caseId": case_id
        }
    }
    try:
        response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(query_get_location_id),
            headers=HEADERS
        )
        return response.json()["data"]["atd_apd_blueform"][0]["location_id"]
    except (IndexError, KeyError, TypeError):
        return None


def update_location(case_id: int, new_location_id: str) -> dict:
    """
    Returns a dictionary and HTTP response from the GraphQL query
    :param int case_id: The case_id of the record to be updated
    :param new_location_id: The new location id for the record
    :return dict:
    """
    if case_id is None:
        raise_critical_error(
            message=f"No case_id provided to update the location",
        )
    # Output
    mutation_response = {}
    # Prepare the query body
    mutation_json_body = {
        "query": """
            mutation updateNonCR3CrashLocationID($caseId: Int!, $locationId: String) {
                update_atd_apd_blueform(where: {case_id: {_eq: $caseId}}, _set: {location_id: $locationId}) {
                    affected_rows
                }
            }
        """,
        "variables": {
            "caseId": case_id,
            "locationId": new_location_id
        },
    }
    # Execute the mutation
    try:
        mutation_response = requests.post(
            HASURA_ENDPOINT,
            data=json.dumps(mutation_json_body),
            headers=HEADERS
        )
    except Exception as e:
        raise_critical_error(
            message=f"Unable to update case_id location: {str(e)}"
        )

    return {
        "status": "Mutation Successful",
        "response": mutation_response.json()
    }


def hasura_request(record: str) -> bool:
    """
    Returns True if the record was processed, False if no need for update.
    :param str record: The json payload from Hasura
    :returns bool:
    """
    # Get data/case_id from Hasura Event request
    data = load_data(record=record)

    # Try getting the crash data
    case_id = get_case_id(data)
    old_location_id = get_location_id(data)

    # Check if this crash is a main-lane
    if is_crash_mainlane(case_id):
        # If so, make sure to nullify the new location_id
        new_location_id = None
    else:
        # If not, then try to find the location...
        new_location_id = find_crash_location(case_id)

    # Now compare the location values:
    if new_location_id == old_location_id:
        # No need to update
        return False

    # There is an update to the location
    else:
        update_location(
            case_id=case_id,
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
