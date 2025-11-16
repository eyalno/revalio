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

    # run once
    # init_db()

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
        "INSERT INTO usage_events (user_id, usage_time) VALUES (%s, %s)",
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
    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("SELECT AVG(usage_time) FROM usage_events;")
        result = cur.fetchone()

        # result = (Decimal or float or None,)
        avg_value = result[0]
        if avg_value is None:
            avg_value = 0

        response = {
            "statusCode": 200,
            "body": json.dumps({"average": float(avg_value)})
        }
    except Exception as e:
        print("ERROR in handle_average:", e)
        response = {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    finally:
        cur.close()
        conn.close()

    return response

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS usage_events (
            id SERIAL PRIMARY KEY,
            user_id VARCHAR(255) NOT NULL,
            usage_time INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        );
    """)
    conn.commit()
    cur.close()
    conn.close()