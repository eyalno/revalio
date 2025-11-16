

# i wasn't able to create secret manager 
same issue with terraform lamnda roles 
dynamo db items

You MUST have psql installed on your local machine where you run Terraform.
brew install postgresql
To install on macOS:


run lambda init 1 time 

curl -X POST "https://v9c9itqce3.execute-api.us-east-2.amazonaws.com/usage" \
  -H "Content-Type: application/json" \
  -d '{"user":"user123","usage":150}'   

  curl -X GET "https://v9c9itqce3.execute-api.us-east-2.amazonaws.com/stats/average"

  {
  "rawPath": "/stats/average",
  "requestContext": {
    "http": {
      "method": "GET"
    }
  }
}

{
  "rawPath": "/usage",
  "requestContext": {
    "http": {
      "method": "POST"
    }
  },
  "body": "{\"user\":\"user123\", \"usage\":150}"
}

Purpose of DynamoDB
	•	Keep fast per-user aggregates
	•	Avoid scanning RDS for every user’s total
	•	Enable constant-time lookups (e.g., in future “user stats” endpoint)

# Usage Tracking Service  
AWS Serverless Architecture – API Gateway → Lambda → RDS (Postgres) + DynamoDB  
Terraform Deployment – VPC with Private Subnets + NAT Gateway

## Overview
This project deploys a production-ready backend for tracking user usage events.  
It exposes two API endpoints:

| Method | Path             | Description                                           |
|--------|------------------|-------------------------------------------------------|
| POST   | `/usage`         | Record a user usage event (write to RDS + DDB)       |
| GET    | `/stats/average` | Returns the average usage time across all users      |

The architecture is secure, scalable, and fully automated by Terraform.

## Architecture Diagram
```
                 +---------------------------+
                 |   API Gateway (HTTP API)  |
                 +--------------+------------+
                                |
                                v
                       +--------+--------+
                       |     Lambda      |
                       |   (Private VPC) |
                       +--------+--------+
                                |
                +---------------+----------------+
                |                                |
                v                                v
    +-------------------------+        +----------------------------+
    |   RDS PostgreSQL        |        | DynamoDB (Aggregates)     |
    |   Private Subnets       |        | usage_aggregates_prod      |
    +-------------------------+        +----------------------------+

      Lambda internet access → via NAT Gateway in public subnet
```

## Repository Structure
```
usage-tracking/
  main.tf
  variables.tf
  outputs.tf
  vpc.tf
  rds.tf
  dynamodb.tf
  lambda.tf
  api_gateway.tf
  usage_handler.zip
```

## Deployment
### Initialize Terraform
terraform init

### Apply Deployment
terraform apply \
  -var="db_username=myuser" \
  -var="db_password=mypassword"

## Database Setup
Connect via psql:
psql -h <db_endpoint> -U myuser -d usage_tracking

Create table:
CREATE TABLE IF NOT EXISTS usage_events (
  id bigserial PRIMARY KEY,
  user_id text NOT NULL,
  usage_time double precision NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

## Testing
POST /usage:
curl -X POST "$API/usage" -H "Content-Type: application/json" -d '{"user_id":"eyal","usage_time":120}'

GET /stats/average:
curl "$API/stats/average"

## Cleanup
terraform destroy
