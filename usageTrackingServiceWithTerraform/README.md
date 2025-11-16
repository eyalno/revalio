
# Design an implementation notes

I was unable to create the Secrets Manager resource due to IAM restrictions, so the RDS username and password are stored directly in variables.tf.

I also could not create the Lambda execution role through Terraform because of permission limits. Instead, the configuration references the execution role that was manually created in the AWS console.
run lambda init 1 time 


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

## Purpose of DynamoDB
	•	Keep fast per-user aggregates
	•	Avoid scanning RDS for every user’s total
	•	Enable constant-time lookups (e.g., in future “user stats” endpoint)


## Deployment

You MUST have psql installed on your local machine where you run Terraform.
brew install postgresql

mkdir /terraform/lambda_layer
cd lambda_layer
mkdir python
pip3 install pg8000 -t python

terraform init

terraform apply

## Testing

curl -X POST "https://YOUR_API_GATEWAY/usage" \
  -H "Content-Type: application/json" \
  -d '{"user":"user123","usage":150}'   

curl -X GET "https://YOUR_API_GATEWAY/stats/average"


## Lambda Testing
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



## Cleanup
terraform destroy
