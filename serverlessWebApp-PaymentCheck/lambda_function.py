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

def lambda_handler(event, context):
    try:
        logger.info(f"Raw event: {event}")

        # Handle both stringified body (API Gateway) and dict (Lambda test)
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)
        elif body is None:
            body = event  # fallback for direct Lambda test events

        username = body.get("username")
        password = body.get("password")

        logger.info(f"Parsed credentials - username: {username}, password: {'***' if password else None}")

        # Check if credentials are provided
        if not username or not password:
            return {
                "statusCode": 400,
                "body": json.dumps({"status": "error", "message": "Missing credentials."})
            }

        # Lookup user in DynamoDB
        logger.info(f"Looking up user in DynamoDB: {username}")
        response = table.get_item(Key={"username": username})
        logger.info(f"DynamoDB response: {response}")

        user = response.get("Item")
        if not user:
            logger.warning(f"User not found: {username}")
            return {
                "statusCode": 401,
                "body": json.dumps({"status": "error", "message": "Invalid credentials."})
            }

        # Verify password using pbkdf2_sha256
        stored_hash = user.get("password_hash")
        if not stored_hash:
            logger.error(f"No password_hash stored for user: {username}")
            return {
                "statusCode": 500,
                "body": json.dumps({"status": "error", "message": "Server misconfiguration."})
            }

        if not pbkdf2_sha256.verify(password, stored_hash):
            logger.warning(f"Password verification failed for user: {username}")
            return {
                "statusCode": 401,
                "body": json.dumps({"status": "error", "message": "Invalid credentials."})
            }

        # Check payment status
        payment_status = user.get("payment_status", "unknown")
        if payment_status == "expired":
            return {
                "statusCode": 200,
                "body": json.dumps({"status": "expired", "message": "Your payment has expired."})
            }

        # Success
        return {
            "statusCode": 200,
            "body": json.dumps({"status": "ok", "message": "Welcome!"})
        }

    except Exception as e:
        logger.exception("Error in Lambda handler")
        return {
            "statusCode": 500,
            "body": json.dumps({"status": "error", "message": "Server error."})
        }