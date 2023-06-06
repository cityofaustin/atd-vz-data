"""
This function is borrowed from https://raw.githubusercontent.com/cityofaustin/atd-vz-data/master/atd-etl/app/process/helpers_import.py.

In our prefect repo, this was made available by a submodule, but I'm going to avoid that here and just bring it in manually
because we will no longer need this function when the LDM goes into service.
"""

import json
import datetime

def insert_crash_change_template(new_record_dict, differences, crash_id):
    """
    Generates a crash insertion graphql query
    :param new_record_dict: dict - The new record as a dictionary
    :param differences
    :param str crash_id
    :return: string
    """

    new_record_crash_date = None
    try: 
        new_record_crash_date = new_record_dict["crash_date"].strftime("%Y-%m-%d")  #convert_date(new_record_dict["crash_date"])
    except:
        print("Failed to convert crash_date")

    for key in new_record_dict:
        if isinstance(new_record_dict[key], datetime.date):
            new_record_dict[key] = new_record_dict[key].strftime("%Y-%m-%d")
        if isinstance(new_record_dict[key], datetime.time):
            new_record_dict[key] = new_record_dict[key].strftime("%H:%M:%S")

        # CRIS or the upstream ETL is representing this datum as a float, so cast it back
        if key == "rpt_sec_speed_limit": 
            new_record_dict[key] = int(new_record_dict[key])

    # Turn the dictionary into a character-escaped json string
    new_record_escaped = json.dumps(json.dumps(new_record_dict), default=str)
    # Build the template and inject required values
    output = (
        """
        mutation insertCrashChangeMutation {
          insert_atd_txdot_changes(
            objects: {
              record_id: %NEW_RECORD_ID%,
              record_json: %NEW_RECORD_ESCAPED_JSON%,
              record_uqid: %NEW_UNIQUE_ID%
              record_type: "crash",
              affected_columns: %AFFECTED_COLUMNS%,
              status_id: 0,
              updated_by: "System",
              crash_date: %NEW_RECORD_CRASH_DATE%
            },
            on_conflict: {
              constraint: atd_txdot_changes_unique,
              update_columns: [
                record_id,
                record_json,
                record_type,
                affected_columns,
                status_id,
                updated_by
                crash_date
              ]
            }
          ) {
            affected_rows
          }
        }
        """.replace(
            "%NEW_RECORD_ESCAPED_JSON%", new_record_escaped
        )
        .replace("%NEW_RECORD_ID%", crash_id)
        .replace("%NEW_UNIQUE_ID%", crash_id)
        .replace("%AFFECTED_COLUMNS%", json.dumps(json.dumps(differences), default=str))
        .replace(
            "%NEW_RECORD_CRASH_DATE%",
            "null" if new_record_crash_date is None else f'"{new_record_crash_date}"',
        )
    )
    return output

