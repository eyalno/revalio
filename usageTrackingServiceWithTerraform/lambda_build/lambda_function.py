import os
import json
import pg8000
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DDB_TABLE_NAME"])

DB_HOST = os.environ["DB_HOST"]
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_NAME = os.environ["DB_NAME"]

def get_db_connection():
    conn = pg8000.connect(
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME
    )
    return conn

def lambda_handler(event, context):
    route = event.get("rawPath")
    method = event.get("requestContext", {}).get("http", {}).get("method")

    if route == "/usage" and method == "POST":
        return handle_usage(event)

    if route == "/stats/average" and method == "GET":
        return handle_average(event)

    return {
        "statusCode": 404,
        "body": json.dumps({"error": "Not found"})
    }

def handle_usage(event):
    # parse incoming JSON
    body = json.loads(event.get("body", "{}"))
    user = body.get("user")
    usage = body.get("usage")

    # write to RDS
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO usage_events (user_id, usage_seconds) VALUES (%s, %s)",
        (user, usage)
    )
    conn.commit()
    cur.close()
    conn.close()

    # update DynamoDB
    table.update_item(
        Key={"user_id": user},
        UpdateExpression="ADD total_usage :u",
        ExpressionAttributeValues={":u": usage},
        ReturnValues="UPDATED_NEW"
    )

    return {"statusCode": 200, "body": json.dumps({"message": "ok"})}

def handle_average(event):
    # example stub
    return {"statusCode": 200, "body": json.dumps({"average": 0})}
