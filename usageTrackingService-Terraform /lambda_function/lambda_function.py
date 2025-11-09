import os
import json
import boto3
import pg8000

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    if event['httpMethod'] == 'POST' and event['path'] == '/usage':
        body = json.loads(event['body'])
        username = body['username']
        usage_time = body['usage_time']

        # Update RDS using pg8000
        conn = pg8000.connect(
            host=os.environ['RDS_ENDPOINT'],
            database=os.environ['RDS_DB'],
            user=os.environ['RDS_USER'],
            password=os.environ['RDS_PASSWORD']
        )
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO usage_events (username, usage_time, created_at) VALUES (%s, %s, NOW())",
            (username, usage_time)
        )
        conn.commit()
        cur.close()
        conn.close()

        # Update DynamoDB
        table.update_item(
            Key={'username': username},
            UpdateExpression="SET total_usage = if_not_exists(total_usage, :zero) + :val, event_count = if_not_exists(event_count, :zero) + :one",
            ExpressionAttributeValues={':val': usage_time, ':one': 1, ':zero': 0},
            ReturnValues="UPDATED_NEW"
        )

        return {'statusCode': 200, 'body': json.dumps({'message': 'Usage recorded'})}

    elif event['httpMethod'] == 'GET' and event['path'] == '/stats/average':
        # Scan DynamoDB to compute average
        response = table.scan()
        total = sum(item['total_usage'] for item in response['Items'])
        count = sum(item['event_count'] for item in response['Items'])
        average = total / count if count > 0 else 0
        return {'statusCode': 200, 'body': json.dumps({'average_usage': average})}

    return {'statusCode': 404, 'body': 'Not Found'}