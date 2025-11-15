import json
import boto3
import logging
from passlib.hash import pbkdf2_sha256  # pure-Python backend

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "user_data"
table = dynamodb.Table(TABLE_NAME)

# CORS headers for all responses
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "OPTIONS,POST"
}

def login_handler(event, context):
    try:
        logger.info(f"Raw event: {event}")

        # Handle OPTIONS preflight automatically
        if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": CORS_HEADERS,
                "body": ""
            }

        # Handle both stringified body and dict
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)
        elif body is None:
            body = event  # fallback for direct Lambda tests

        username = body.get("username")
        password = body.get("password")

        if not username or not password:
            return {
                "statusCode": 400,
                "headers": CORS_HEADERS,
                "body": json.dumps({"status": "error", "message": "Missing credentials."})
            }

        # Look up user
        response = table.get_item(Key={"username": username})
        user = response.get("Item")

        if not user:
            return {
                "statusCode": 401,
                "headers": CORS_HEADERS,
                "body": json.dumps({"status": "error", "message": "Invalid credentials."})
            }

        # Verify password
        stored_hash = user.get("password_hash")
        if not pbkdf2_sha256.verify(password, stored_hash):
            return {
                "statusCode": 401,
                "headers": CORS_HEADERS,
                "body": json.dumps({"status": "error", "message": "Invalid credentials."})
            }

        # Check payment status
        if user.get("payment_status") == "expired":
            return {
                "statusCode": 200,
                "headers": CORS_HEADERS,
                "body": json.dumps({"status": "expired", "message": "Your payment has expired."})
            }

        # Success
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"status": "ok", "message": "Welcome!"})
        }

    except Exception as e:
        logger.exception("Error in Lambda handler")
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"status": "error", "message": "Server error."})
        }