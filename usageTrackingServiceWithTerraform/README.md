# Usage Tracking Service

AWS Serverless Architecture -- API Gateway → Lambda → RDS (PostgreSQL) +
DynamoDB\
Provisioned with Terraform


## Overview

This project deploys a production-ready backend for tracking user usage
events.

It exposes two API endpoints:

  ---------------------------------------------------------------------------
  Method   Path               Description
  -------- ------------------ -----------------------------------------------
  POST     `/usage`           Record a usage event (writes to RDS + DynamoDB)

  GET      `/stats/average`   Return average usage across all users
  ---------------------------------------------------------------------------

The system runs entirely within a private VPC and is deployed using
Terraform.

## Architecture Diagram

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

## Repository Structure

    usage-tracking/
      main.tf
      variables.tf
      outputs.tf
      vpc.tf
      rds.tf
      dynamodb.tf
      lambda.tf
      api_gateway.tf
      lambda_init_src/
      lambda_src/

## Why DynamoDB Is Used

-   Maintain fast per-user aggregates\
-   Avoid scanning RDS for totals\
-   Provide constant-time lookups for user analytics\
-   Reduce load on the relational database

## Design & Implementation Notes

-   Secrets Manager could not be created due to IAM restrictions, so the
    RDS username and password are stored in `variables.tf`.\
-   The Lambda execution role also could not be created via Terraform
    because of permission limits. Terraform therefore references the
    execution role that was created manually in the AWS console.\
-   The `InitDB-Lambda` function runs one time during deployment to
    initialize the database schema.

## Dependencies

Install PostgreSQL client:

    brew install postgresql

Install Python dependency `pg8000` directly into the Lambda source
directories:

    pip install pg8000 -t lambda_init_src
    pip install pg8000 -t lambda_src

## Deployment

Initialize Terraform:

    terraform init

Deploy:

    terraform apply

Terraform will:

-   Create the VPC, subnets, and NAT Gateway\
-   Provision RDS (PostgreSQL)\
-   Create DynamoDB table\
-   Deploy Lambda functions\
-   Deploy API Gateway\
-   Run DB initialization Lambda once

## Testing the API

### POST /usage

    curl -X POST "https://YOUR_API/usage" \
      -H "Content-Type: application/json" \
      -d '{"user":"user123","usage":150}'

### GET /stats/average

    curl -X GET "https://YOUR_API/stats/average"

## Lambda Event Examples

### GET /stats/average

``` json
{
  "rawPath": "/stats/average",
  "requestContext": {
    "http": {
      "method": "GET"
    }
  }
}
```

### POST /usage

``` json
{
  "rawPath": "/usage",
  "requestContext": {
    "http": {
      "method": "POST"
    }
  },
  "body": "{\"user\":\"user123\", \"usage\":150}"
}
```

## Cleanup

lambda init can be deleted adter deployment.

Destroy all resources:

    terraform destroy
