#
# ATD - CR3 Download API
#

import json
import re
import datetime
import boto3
import os
import requests
import hashlib

from dotenv import load_dotenv, find_dotenv
from os import environ as env
from functools import wraps
from six.moves.urllib.request import urlopen
from string import Template

from flask import Flask, request, redirect, jsonify, _request_ctx_stack, abort
from flask_cors import cross_origin
from werkzeug.local import LocalProxy
from jose import jwt

#
# Environment
#
ENV_FILE = find_dotenv()
if ENV_FILE:
    load_dotenv(ENV_FILE, verbose=True)

# We need the Auth0 domain, Client ID and current api environment.
AUTH0_DOMAIN = os.getenv("AUTH0_DOMAIN", "")
CLIENT_ID = os.getenv("CLIENT_ID", "")
API_CLIENT_ID = os.getenv("API_CLIENT_ID", "")
API_CLIENT_SECRET = os.getenv("API_CLIENT_SECRET", "")
API_ENVIRONMENT = os.getenv("API_ENVIRONMENT", "STAGING")

# AWS Configuration
AWS_DEFALUT_REGION = os.getenv("AWS_DEFALUT_REGION", "us-east-1")
AWS_S3_KEY = os.getenv("AWS_S3_KEY", "")
AWS_S3_SECRET = os.getenv("AWS_S3_SECRET", "")
AWS_S3_CR3_LOCATION = os.getenv("AWS_S3_CR3_LOCATION", "")
AWS_S3_BUCKET = os.getenv("AWS_S3_BUCKET", "")

# Hasura Config
HASURA_ADMIN_SECRET = os.getenv("HASURA_ADMIN_SECRET", "")
HASURA_ENDPOINT = os.getenv("HASURA_ENDPOINT", "")
HASURA_TRIGGER_API_KEY = os.getenv("HASURA_TRIGGER_API_KEY", "")
HASURA_EVENTS_SQS_URL = os.getenv("HASURA_EVENTS_SQS_URL", "")


def get_api_token():
    """
    Obtains a token from the Auth0 API
    :return str:
    """
    response = requests.post(
        f"https://{AUTH0_DOMAIN}/oauth/token",
        {
            "grant_type": "client_credentials",
            "client_id": API_CLIENT_ID,
            "client_secret": API_CLIENT_SECRET,
            "audience": f"https://{AUTH0_DOMAIN}/api/v2/",
        },
        {
            "content-type": "application/json",
        },
    )
    return response.json().get("access_token", None)


CORS_URL = "*"
ALGORITHMS = ["RS256"]
APP = Flask(__name__)


# Format error response and append status code.
class AuthError(Exception):
    def __init__(self, error, status_code):
        self.error = error
        self.status_code = status_code


@APP.errorhandler(AuthError)
def handle_auth_error(ex):
    response = jsonify(ex.error)
    response.status_code = ex.status_code
    return response


def get_token_auth_header():
    """Obtains the access token from the Authorization Header"""
    auth = request.headers.get("Authorization", None)
    if not auth:
        raise AuthError(
            {
                "code": "authorization_header_missing",
                "description": "Authorization header is expected",
            },
            401,
        )

    parts = auth.split()

    if parts[0].lower() != "bearer":
        raise AuthError(
            {
                "code": "invalid_header",
                "description": "Authorization header must start with" " Bearer",
            },
            401,
        )
    elif len(parts) == 1:
        raise AuthError(
            {"code": "invalid_header", "description": "Token not found"}, 401
        )
    elif len(parts) > 2:
        raise AuthError(
            {
                "code": "invalid_header",
                "description": "Authorization header must be" " Bearer token",
            },
            401,
        )

    token = parts[1]
    return token


def requires_scope(required_scope):
    """Determines if the required scope is present in the access token
    Args:
        required_scope (str): The scope required to access the resource
    """
    token = get_token_auth_header()
    unverified_claims = jwt.get_unverified_claims(token)
    if unverified_claims.get("scope"):
        token_scopes = unverified_claims["scope"].split()
        for token_scope in token_scopes:
            if token_scope == required_scope:
                return True
    return False


def requires_auth(f):
    """Determines if the access token is valid"""

    @wraps(f)
    def decorated(*args, **kwargs):
        token = get_token_auth_header()
        jsonurl = urlopen("https://" + AUTH0_DOMAIN + "/.well-known/jwks.json")
        jwks = json.loads(jsonurl.read())
        try:
            unverified_header = jwt.get_unverified_header(token)
        except jwt.JWTError:
            raise AuthError(
                {
                    "code": "invalid_header",
                    "description": "Invalid header. "
                    "Use an RS256 signed JWT Access Token",
                },
                401,
            )
        if unverified_header["alg"] == "HS256":
            raise AuthError(
                {
                    "code": "invalid_header",
                    "description": "Invalid header. "
                    "Use an RS256 signed JWT Access Token",
                },
                401,
            )
        rsa_key = {}
        for key in jwks["keys"]:
            if key["kid"] == unverified_header["kid"]:
                rsa_key = {
                    "kty": key["kty"],
                    "kid": key["kid"],
                    "use": key["use"],
                    "n": key["n"],
                    "e": key["e"],
                }
        if rsa_key:
            dataConfig = {
                "verify_signature": True,
                "verify_aud": True,
                "verify_iat": True,
                "verify_exp": True,
                "verify_nbf": False,
                "verify_iss": True,
                "verify_sub": True,
                "verify_jti": False,
                "verify_at_hash": False,
                "leeway": 0,
            }
            try:
                payload = jwt.decode(
                    token,
                    rsa_key,
                    algorithms=ALGORITHMS,
                    issuer="https://" + AUTH0_DOMAIN + "/",
                    audience=CLIENT_ID,
                    options=dataConfig,
                )
            except jwt.ExpiredSignatureError:
                raise AuthError(
                    {"code": "token_expired", "description": "token is expired"}, 401
                )
            except jwt.JWTClaimsError:
                raise AuthError(
                    {
                        "code": "invalid_claims",
                        "description": "incorrect claims,"
                        " please check the audience and issuer",
                    },
                    401,
                )
            except Exception:
                raise AuthError(
                    {
                        "code": "invalid_header",
                        "description": "Unable to parse authentication" " token.",
                    },
                    401,
                )
            _request_ctx_stack.top.current_user = payload
            return f(*args, **kwargs)
        raise AuthError(
            {"code": "invalid_header", "description": "Unable to find appropriate key"},
            401,
        )

    return decorated


current_user = LocalProxy(lambda: getattr(_request_ctx_stack.top, "current_user", None))

# Controllers API


@APP.route("/")
@cross_origin(headers=["Content-Type", "Authorization"])
def healthcheck():
    """No access token required to access this route"""
    now = datetime.datetime.now()
    response = "CR3 Download API - Health Check - Available @ %s" % now.strftime(
        "%Y-%m-%d %H:%M:%S"
    )
    return jsonify(message=response)


@APP.route("/cr3/download/<crash_id>")
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def download_crash_id(crash_id):
    """A valid access token is required to access this route"""
    # We only care for an integer string, anything else is not safe:
    safe_crash_id = re.sub("[^0-9]", "", crash_id)

    s3 = boto3.client(
        "s3",
        region_name=AWS_DEFALUT_REGION,
        aws_access_key_id=AWS_S3_KEY,
        aws_secret_access_key=AWS_S3_SECRET,
    )

    url = s3.generate_presigned_url(
        ExpiresIn=60,  # seconds
        ClientMethod="get_object",
        Params={
            "Bucket": AWS_S3_BUCKET,
            "Key": AWS_S3_CR3_LOCATION + "/" + safe_crash_id + ".pdf",
        },
    )

    # For testing uncomment:
    # response = "Private Download, CrashID: %s , %s" % (safe_crash_id, url)
    # return redirect(url, code=302)
    return jsonify(message=url)


def isValidUser(user_dict):
    valid_fields = [
        "email",
        "name",
        "https://hasura.io/jwt/claims",
        "email_verified",
        "aud",
    ]

    user_email = user_dict.get("email", None)

    # Check for valid fields
    for field in valid_fields:
        if user_dict.get(field, False) == False:
            return False

    # Check for verified email
    if user_dict["email_verified"] != True:
        return False

    # Check email for austintexas.gov
    if str(user_email).endswith("@austintexas.gov") is False:
        return False

    return True


def hasUserRole(role, user_dict):
    claims = user_dict.get("https://hasura.io/jwt/claims", False)
    if claims != False:
        roles = claims.get("x-hasura-allowed-roles")
        if role in roles:
            return True
    return False


@APP.route("/user/test")
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_test():
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict):
        return jsonify(message=current_user._get_current_object())
    else:
        abort(403)


@APP.route("/user/list_users")
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_list_users():
    user_dict = current_user._get_current_object()
    page = request.args.get("page")
    per_page = request.args.get("per_page")
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/users?page=" + page + "&per_page=" + per_page + "&include_totals=true"
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.get(endpoint, headers=headers).json()
        return jsonify(response)
    else:
        abort(403)


@APP.route("/user/get_user/<id>")
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_get_user(id):
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/users/" + id
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.get(endpoint, headers=headers).json()
        return jsonify(response)
    else:
        abort(403)


@APP.route("/user/create_user", methods=["POST"])
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_create_user():
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        json_data = request.json
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/users"
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.post(endpoint, headers=headers, json=json_data).json()
        return jsonify(response)
    else:
        abort(403)


@APP.route("/user/update_user/<id>", methods=["PUT"])
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_update_user(id):
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        json_data = request.json
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/users/" + id
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.patch(endpoint, headers=headers, json=json_data).json()
        return jsonify(response)
    else:
        abort(403)


@APP.route("/user/unblock_user/<id>", methods=["DELETE"])
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_unblock_user(id):
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/user_blocks/" + id
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.delete(endpoint, headers=headers)
        return f"{response.status_code}"
    else:
        abort(403)


@APP.route("/user/delete_user/<id>", methods=["DELETE"])
@cross_origin(headers=["Content-Type", "Authorization"])
@cross_origin(headers=["Access-Control-Allow-Origin", CORS_URL])
@requires_auth
def user_delete_user(id):
    user_dict = current_user._get_current_object()
    if isValidUser(user_dict) and hasUserRole("admin", user_dict):
        endpoint = f"https://{AUTH0_DOMAIN}/api/v2/users/" + id
        headers = {"Authorization": f"Bearer {get_api_token()}"}
        response = requests.delete(endpoint, headers=headers)
        return f"{response.status_code}"
    else:
        abort(403)


@APP.route("/events/", methods=["PUT", "POST"])
def associate_location():
    # Require matching token
    incoming_token = request.headers.get("HASURA_TRIGGER_API_KEY")
    incoming_event_name = request.headers.get("HASURA_EVENT_NAME", "")
    environment_for_queue_name = API_ENVIRONMENT.lower()
    hashed_events_api = hashlib.md5()
    hashed_events_api.update(str(HASURA_TRIGGER_API_KEY).encode("utf-8"))
    hashed_incoming_token = hashlib.md5()
    hashed_incoming_token.update(str(incoming_token).encode("utf-8"))

    # Return error if token doesn't match
    if hashed_events_api.hexdigest() != hashed_incoming_token.hexdigest():
        return {"statusCode": 403, "body": json.dumps({"message": "Forbidden Request"})}

    # Check if there is a valid event name provided, if not reject the request.
    valid_event_names = [
        "crash_update_noncr3_location_",
        "crash_update_jurisdiction_",
        "crash_update_location_",
    ]

    if incoming_event_name not in valid_event_names:
        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Forbidden Request: Invalid Event Name"}),
        }

    # We continue the execution
    try:
        sqs = boto3.client("sqs")
        queue_url = (
            # The SQS url is a constant that follows this pattern:
            # https://sqs.us-east-1.amazonaws.com/{AWS_ACCOUNT_NUMBER}/{THE_QUEUE_NAME}
            HASURA_EVENTS_SQS_URL[
                0:48
            ]  # This is the length of the url with the account number
            + "/atd-vz-data-events-"  # We're going to add a prefix pattern for our ATD VisionZero queues
            + incoming_event_name  # And append the name of the incoming event
            + environment_for_queue_name  # Append the environment name to target the correct queue
        )

        # Send message to SQS queue
        response = sqs.send_message(
            QueueUrl=queue_url,
            DelaySeconds=10,
            MessageBody=json.dumps(request.get_json(force=True)),
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": "Update queued: " + str(response["MessageId"])}
            ),
        }
    except Exception as e:
        return {
            "statusCode": 503,
            "body": json.dumps(
                {"message": "Unable to queue update request: " + str(e)}
            ),
        }


if __name__ == "__main__":
    APP.run(host="0.0.0.0", port=env.get("PORT", 3010))
