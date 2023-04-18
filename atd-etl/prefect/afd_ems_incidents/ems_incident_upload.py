#!/usr/bin/env python

"""
Name: EMS Incident Uploads
Description: This flow uploads EMS Incident Response CSVs (EMS Contact: Lynn C). 
    The data is emailed to atd-ems-incident-data@austinmobility.io daily ~ 3:30AM. From there it
    gets forwarded to a S3 bucket via AWS Simple Email Service.
"""

import prefect
from prefect import Flow, task, Parameter, case
import datetime
import json
import os
import boto3
import pprint
import time
import email
import tempfile
import shutil
import pandas
from datetime import datetime, timedelta
import psycopg2
import psycopg2.extras
from psycopg2 import Error
from prefect.storage import GitHub
from prefect.run_configs import UniversalRun
from prefect.backend import get_key_value
from sshtunnel import SSHTunnelForwarder

pp = pprint.PrettyPrinter(indent=4)

kv_data = get_key_value(key="Vision Zero Development")
environment_variables_from_kv_store = json.loads(kv_data)

# Retrieve the db configuration
DB_USERNAME = None
DB_PASSWORD = None
DB_HOSTNAME = None
DB_PORT = None
DB_DATABASE = None
AWS_ACCESS_KEY_ID = None
AWS_SECRET_ACCESS_KEY = None
AFD_S3_SOURCE_BUCKET = None
AFD_S3_ARCHIVE_BUCKET = None
AFD_S3_SOURCE_PREFIX = None
AFD_S3_ARCHIVE_PREFIX = None
EMS_S3_SOURCE_BUCKET = None
EMS_S3_ARCHIVE_BUCKET = None
EMS_S3_SOURCE_PREFIX = None
EMS_S3_ARCHIVE_PREFIX = None
DB_BASTION_HOST = None
DB_RDS_HOST = None

if False:
    # Retrieve the db configuration
    DB_USERNAME = environment_variables_from_kv_store["AFD_DB_USERNAME"]
    DB_PASSWORD = environment_variables_from_kv_store["AFD_DB_PASSWORD"]
    DB_HOSTNAME = environment_variables_from_kv_store["AFD_DB_HOSTNAME"]
    DB_PORT = environment_variables_from_kv_store["AFD_DB_PORT"]
    DB_DATABASE = environment_variables_from_kv_store["AFD_DB_DATABASE"]
    AWS_ACCESS_KEY_ID = environment_variables_from_kv_store["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_ACCESS_KEY = environment_variables_from_kv_store["AWS_SECRET_ACCESS_KEY"]
    AFD_S3_SOURCE_BUCKET = environment_variables_from_kv_store["AFD_S3_SOURCE_BUCKET"]
    AFD_S3_ARCHIVE_BUCKET = environment_variables_from_kv_store["AFD_S3_ARCHIVE_BUCKET"]
    AFD_S3_SOURCE_PREFIX = environment_variables_from_kv_store["AFD_S3_SOURCE_PREFIX"]
    AFD_S3_ARCHIVE_PREFIX = environment_variables_from_kv_store["AFD_S3_ARCHIVE_PREFIX"]
    EMS_S3_SOURCE_BUCKET = environment_variables_from_kv_store["EMS_S3_SOURCE_BUCKET"]
    EMS_S3_ARCHIVE_BUCKET = environment_variables_from_kv_store["EMS_S3_ARCHIVE_BUCKET"]
    EMS_S3_SOURCE_PREFIX = environment_variables_from_kv_store["EMS_S3_SOURCE_PREFIX"]
    EMS_S3_ARCHIVE_PREFIX = environment_variables_from_kv_store["EMS_S3_ARCHIVE_PREFIX"]
    DB_BASTION_HOST = environment_variables_from_kv_store["DB_BASTION_HOST"]
    DB_RDS_HOST = environment_variables_from_kv_store["DB_RDS_HOST"]
else:
    DB_USERNAME = os.getenv("AFD_DB_USERNAME")
    DB_PASSWORD = os.getenv("AFD_DB_PASSWORD")
    DB_HOSTNAME = os.getenv("AFD_DB_HOSTNAME")
    DB_PORT = os.getenv("AFD_DB_PORT")
    DB_DATABASE = os.getenv("AFD_DB_DATABASE")
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AFD_S3_SOURCE_BUCKET = os.getenv("AFD_S3_SOURCE_BUCKET")
    AFD_S3_ARCHIVE_BUCKET = os.getenv("AFD_S3_ARCHIVE_BUCKET")
    AFD_S3_SOURCE_PREFIX = os.getenv("AFD_S3_SOURCE_PREFIX")
    AFD_S3_ARCHIVE_PREFIX = os.getenv("AFD_S3_ARCHIVE_PREFIX")
    EMS_S3_SOURCE_BUCKET = os.getenv("EMS_S3_SOURCE_BUCKET")
    EMS_S3_ARCHIVE_BUCKET = os.getenv("EMS_S3_ARCHIVE_BUCKET")
    EMS_S3_SOURCE_PREFIX = os.getenv("EMS_S3_SOURCE_PREFIX")
    EMS_S3_ARCHIVE_PREFIX = os.getenv("EMS_S3_ARCHIVE_PREFIX")
    DB_BASTION_HOST = os.getenv("DB_BASTION_HOST")
    DB_RDS_HOST = os.getenv("DB_RDS_HOST")



@task
def get_timestamp():
    current = datetime.now()
    return time.mktime(current.timetuple())


@task
def get_most_recent_email():
    """
    Find the most recently updated file in the bucket. This will be the newest email.
    :return: string
    """

    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )
    s3 = session.resource("s3")

    bucket = s3.Bucket(EMS_S3_SOURCE_BUCKET)

    files = []
    for file in bucket.objects.filter(Prefix=EMS_S3_SOURCE_PREFIX):
        files.append(file)
    files.sort(key=lambda x: x.last_modified, reverse=True)

    file = files[0].get()
    email = file["Body"].read().decode("utf-8")

    return email


@task
def extract_email_attachment(message):
    # Given the s3 object content is the SES email,
    # get the message content and attachment using email package
    msg = email.message_from_string(message)
    attachment = msg.get_payload()[1]

    tmpdir = tempfile.mkdtemp()

    logger = prefect.context.get("logger")
    logger.info(f"Tmpdir: {tmpdir}")

    # Write the attachment to a temp location
    open(f"{tmpdir}/attachment.csv", "wb").write(attachment.get_payload(decode=True))
    return tmpdir


@task
def upload_attachment_to_S3(location, timestamp):
    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )
    s3 = session.resource("s3")

    s3.Bucket(EMS_S3_ARCHIVE_BUCKET).upload_file(
        f"{location}/attachment.csv",
        f"{EMS_S3_ARCHIVE_PREFIX}upload-{timestamp}.csv",
    )
    return True


@task
def create_and_parse_dataframe(location):
    # Parse CSV into pandas dataframe
    data = pandas.read_csv(f"{location}/attachment.csv", header=0, on_bad_lines='skip',  encoding='ISO-8859-1')
    return data


@task
def upload_data_to_postgres(data, age_cutoff):
    
    ssh_tunnel = SSHTunnelForwarder(
        (DB_BASTION_HOST),
        ssh_username="vz-etl",
        ssh_private_key= '/root/.ssh/id_rsa', # will switch to ed25519 when we rebuild this for prefect 2
        remote_bind_address=(DB_RDS_HOST, 5432)
        )
    ssh_tunnel.start() 

    pg = psycopg2.connect(
        host='localhost', 
        port=ssh_tunnel.local_bind_port,
        user=DB_USERNAME,
        password=DB_PASSWORD,
        dbname=DB_DATABASE
    )

    print(f"Max record age: {age_cutoff}")
    print(f"Input Dataframe shape: {data.shape}")
    if age_cutoff > 0:
        data["Incident_Date_Received"] = pandas.to_datetime(data["Incident_Date_Received"], format="%Y-%m-%d")
        age_threshold = datetime.today() - timedelta(days=age_cutoff)
        data = data[data["Incident_Date_Received"] > age_threshold]
    print(f"Trimmed data shape: {data.shape}")
    print(data)

    # this emits indices in reverse order, very odd, but not a problem
    for index, row in data.iloc[::-1].iterrows():
        if not index % 100:
            print(f"Row {str(index)} of {str(data.shape[0])}")
        #print(data["Incident_Date_Received"][index])

        apd_incident_numbers = str(row["APD_Incident_Numbers"]).replace("-", "").replace(" ", "").split(",")
        apd_incident_numbers[:] = (value for value in apd_incident_numbers if not value == 'nan')
        if len(apd_incident_numbers) > 1:
            pass
            # print(f"🛎 Found multiple incident numbers: " + str(row["EMS_IncidentNumber"]))

        sql = "select count(id) as existing from ems__incidents where incident_number = %s"

        cursor = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute(sql, (row["Incident_Number"],))
        existing = cursor.fetchone()

        sql = ""
        values = []        

        if existing["existing"] > 0:
            #print("Update")
            sql = """
                update ems__incidents set
                    incident_date_received = %s,
                    incident_time_received = %s,
                    incident_number = %s,
                    incident_location_address = %s,
                    incident_location_city = %s,
                    incident_location_state = %s,
                    incident_location_zip = %s,
                    incident_location_longitude = %s,
                    incident_location_latitude = %s,
                    incident_problem = %s,
                    incident_priority_number = %s,
                    pcr_cause_of_injury = %s,
                    pcr_patient_complaints = %s,
                    pcr_provider_impression_primary = %s,
                    pcr_provider_impression_secondary = %s,
                    pcr_outcome = %s,
                    pcr_transport_destination = %s,
                    pcr_patient_acuity_level = %s,
                    pcr_patient_acuity_level_reason = %s,
                    pcr_patient_age = %s,
                    pcr_patient_gender = %s,
                    pcr_patient_race = %s,
                    mvc_form_airbag_deployment = %s,
                    mvc_form_airbag_deployment_status = %s,
                    mvc_form_collision_indicators = %s,
                    mvc_form_damage_location = %s,
                    mvc_form_estimated_speed_kph = %s,
                    mvc_form_estimated_speed_mph = %s,
                    mvc_form_extrication_comments = %s,
                    mvc_form_extrication_datetime = %s,
                    mvc_form_extrication_required_flag = %s,
                    mvc_form_patient_injured_flag = %s,
                    mvc_form_position_in_vehicle = %s,
                    mvc_form_safety_devices = %s,
                    mvc_form_seat_row_number = %s,
                    mvc_form_vehicle_type = %s,
                    mvc_form_weather = %s,
                    pcr_additional_agencies = %s,
                    pcr_transport_priority = %s,
                    unparsed_apd_incident_numbers = %s,
                    pcr_patient_acuity_initial = %s,
                    pcr_patient_acuity_final = %s,
                    geometry = ST_SetSRID(ST_Point(%s, %s), 4326),
                    apd_incident_numbers = %s
                where pcr_key = %s
                
            """
            values = [
                row["Incident_Date_Received"],
                row["Incident_Time_Received"],
                row["Incident_Number"],
                row["Incident_Location_Address"],
                row["Incident_Location_City"],
                row["Incident_Location_State"],
                row["Incident_Location_Zip"],
                row["Incident_Location_Longitude"],
                row["Incident_Location_Latitude"],
                row["Incident_Problem"],
                row["Incident_Priority_Number"],
                row["PCR_Cause_of_Injury"],
                row["PCR_Patient_Complaints"],
                row["PCR_Provider_Impression_Primary"],
                row["PCR_Provider_Impression_Secondary"],
                row["PCR_Outcome"],
                row["PCR_Transport_Destination"],
                row["PCR_Patient_Acuity_Level"],
                row["PCR_Patient_Acuity_Level_Reason"],
                row["PCR_Patient_Age"],
                row["PCR_Patient_Gender"],
                row["PCR_Patient_Race"],
                row["MVC_Form_Airbag_Deployment"],
                row["MVC_Form_Airbag_Deployment_Status"],
                row["MVC_Form_Collision_Indicators"],
                row["MVC_Form_Damage_Location"],
                row["MVC_Form_Estimated_Speed_Kph"],
                row["MVC_Form_Estimated_Speed_Mph"],
                row["MVC_Form_Extrication_Comments"],
                row["MVC_Form_Extrication_Time"],
                row["MVC_Form_Extrication_Required_Flag"],
                row["MVC_Form_Patient_Injured_Flag"],
                row["MVC_Form_Position_In_Vehicle"],
                row["MVC_Form_Safety_Devices"],
                row["MVC_Form_Seat_Row_Number"],
                row["MVC_Form_Vehicle_Type"],
                row["MVC_Form_Weather"],
                row["PCR_Additional_Agencies"],
                row["PCR_Transport_Priority"],
                row["APD_Incident_Numbers"],
                row["PCR_Patient_Acuity_Initial"],
                row["PCR_Patient_Acuity_Final"],
                row["Incident_Location_Longitude"],
                row["Incident_Location_Latitude"],
                "{" + ", ".join(apd_incident_numbers) + "}",
                row["PCR_Key"]
            ]

            for i in range(len(values)):
                if pandas.isna(values[i]):
                    values[i] = None
        else:
            #print("Insert")
            sql = """
                insert into ems__incidents (
                    pcr_key, 
                    incident_date_received,
                    incident_time_received,
                    incident_number,
                    incident_location_address,
                    incident_location_city,
                    incident_location_state,
                    incident_location_zip,
                    incident_location_longitude,
                    incident_location_latitude,
                    incident_problem,
                    incident_priority_number,
                    pcr_cause_of_injury,
                    pcr_patient_complaints,
                    pcr_provider_impression_primary,
                    pcr_provider_impression_secondary,
                    pcr_outcome,
                    pcr_transport_destination,
                    pcr_patient_acuity_level,
                    pcr_patient_acuity_level_reason,
                    pcr_patient_age,
                    pcr_patient_gender,
                    pcr_patient_race,
                    mvc_form_airbag_deployment,
                    mvc_form_airbag_deployment_status,
                    mvc_form_collision_indicators,
                    mvc_form_damage_location,
                    mvc_form_estimated_speed_kph,
                    mvc_form_estimated_speed_mph,
                    mvc_form_extrication_comments,
                    mvc_form_extrication_datetime,
                    mvc_form_extrication_required_flag,
                    mvc_form_patient_injured_flag,
                    mvc_form_position_in_vehicle,
                    mvc_form_safety_devices,
                    mvc_form_seat_row_number,
                    mvc_form_vehicle_type,
                    mvc_form_weather,
                    pcr_additional_agencies,
                    pcr_transport_priority,
                    unparsed_apd_incident_numbers,
                    pcr_patient_acuity_initial,
                    pcr_patient_acuity_final,
                    geometry,
                    apd_incident_numbers
                ) values (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                    %s, %s, %s, ST_SetSRID(ST_Point(%s, %s), 4326),
                    %s
                ) ON CONFLICT DO NOTHING;
            """
            values = [
                row["PCR_Key"],
                row["Incident_Date_Received"],
                row["Incident_Time_Received"],
                row["Incident_Number"],
                row["Incident_Location_Address"],
                row["Incident_Location_City"],
                row["Incident_Location_State"],
                row["Incident_Location_Zip"],
                row["Incident_Location_Longitude"],
                row["Incident_Location_Latitude"],
                row["Incident_Problem"],
                row["Incident_Priority_Number"],
                row["PCR_Cause_of_Injury"],
                row["PCR_Patient_Complaints"],
                row["PCR_Provider_Impression_Primary"],
                row["PCR_Provider_Impression_Secondary"],
                row["PCR_Outcome"],
                row["PCR_Transport_Destination"],
                row["PCR_Patient_Acuity_Level"],
                row["PCR_Patient_Acuity_Level_Reason"],
                row["PCR_Patient_Age"],
                row["PCR_Patient_Gender"],
                row["PCR_Patient_Race"],
                row["MVC_Form_Airbag_Deployment"],
                row["MVC_Form_Airbag_Deployment_Status"],
                row["MVC_Form_Collision_Indicators"],
                row["MVC_Form_Damage_Location"],
                row["MVC_Form_Estimated_Speed_Kph"],
                row["MVC_Form_Estimated_Speed_Mph"],
                row["MVC_Form_Extrication_Comments"],
                row["MVC_Form_Extrication_Time"],
                row["MVC_Form_Extrication_Required_Flag"],
                row["MVC_Form_Patient_Injured_Flag"],
                row["MVC_Form_Position_In_Vehicle"],
                row["MVC_Form_Safety_Devices"],
                row["MVC_Form_Seat_Row_Number"],
                row["MVC_Form_Vehicle_Type"],
                row["MVC_Form_Weather"],
                row["PCR_Additional_Agencies"],
                row["PCR_Transport_Priority"],
                row["APD_Incident_Numbers"],
                row["PCR_Patient_Acuity_Initial"],
                row["PCR_Patient_Acuity_Final"],
                row["Incident_Location_Longitude"],
                row["Incident_Location_Latitude"],
                "{" + ", ".join(apd_incident_numbers) + "}",
            ]

            for i in range(len(values)):
                if pandas.isna(values[i]):
                    values[i] = None

        try:
            cursor = pg.cursor()
            cursor.execute(sql, values)
            pg.commit()
        except Exception as error:
            print(f"Error executing:\n\n{sql}\n")
            print(f"Values: {values}")
            print(f"Error: {error}")
            pg.rollback()

    return True


@task
def clean_up(path):
    # Clean up the temp location
    shutil.rmtree(path)


with Flow("EMS Import ETL") as flow:
    record_age_maximum = Parameter("record_age_maximum", default=0)
    timestamp = get_timestamp()
    newest_email = get_most_recent_email()
    attachment_location = extract_email_attachment(newest_email)
    uploaded_token = upload_attachment_to_S3(attachment_location, timestamp)
    data = create_and_parse_dataframe(attachment_location)
    upload_token = upload_data_to_postgres(data, record_age_maximum)
    clean_up_token = clean_up(attachment_location, upstream_tasks=[upload_token])

# you can use record_age_maximum=0 if you want a full import
flow.run(parameters=dict(record_age_maximum=90))
# f.register(project_name="vision-zero")
