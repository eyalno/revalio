# Serverless Web Application with Payment Check

This repository contains a **static serverless web application** hosted on **S3** and delivered through **CloudFront**, with backend authentication handled by **API Gateway**, **Lambda**, and **DynamoDB**.

which means:
- CloudFront serves **static files only**.
- API Gateway is called **directly** from the frontend.
- CloudFront does not forward API traffic.
- Simpler, stable, and avoids CloudFront behavior complexity.

---

# Architecture Overview

```
                           +----------------------+
                           |        Browser       |
                           |     (User Device)    |
                           +----------+-----------+
                                      |
                           Static UI  |  POST /login
                                      |
                +---------------------+----------------------+
                |                                            |
                v                                            v
+-----------------------------+              +-----------------------------+
|        CloudFront           |              |      API Gateway (HTTP)     |
|   dxxxxxxxxxxxxxx.cloudfront.net           |  https://API_ID.../dev/login |
+-----------------------------+              +-------------+---------------+
                |                                            |
                |  GET /index.html                           |  POST /dev/login
                |  GET /script.js                            |
                |  GET /style.css                            |
                v                                            v
+-----------------------------+              +-----------------------------+
|             S3              |              |           Lambda            |
|    Static Web Assets        |              |    login_handler.py         |
+-----------------------------+              +-------------+---------------+
                                                              |
                                                              v
                                            +-----------------------------+
                                            |           DynamoDB          |
                                            |         user_data           |
                                            +-----------------------------+
```

---

# Repository Structure

| File | Description |
|------|-------------|
| `FrontEnd/index.html` | UI for login |
| `FrontEnd/script.js` | Sends login request to API Gateway |
| `FrontEnd/style.css` | CSS styling |
| `terraform/` | Terraform IaC for entire system |
| `terraform/login_handler.py` | Lambda authentication logic |
| `hash.py` | Generates password hashes using passlib |

---

# Deployment (2 Step Method)
This avoids S3 and CloudFront circular dependencies.

## Step 1: Deploy S3 and CloudFront Only
make sure you are pointing to the right enviornment:
echo $AWS_PROFILE
echo $AWS_REGION

Run inside the `terraform/` directory:

```
terraform init
```

```
terraform apply   -target=aws_s3_bucket.static_site   -target=aws_s3_bucket_versioning.static_site_versioning   -target=aws_s3_bucket_server_side_encryption_configuration.static_site_sse   -target=aws_cloudfront_origin_access_control.oac   -target=aws_cloudfront_distribution.cdn   -auto-approve
```

After deployment, get your CloudFront domain ():

```
aws cloudfront list-distributions --query "DistributionList.Items[*].DomainName" --output text
```

Update your `FrontEnd/script.js`:

```
const API_URL = "https://YOUR_API_ID.execute-api.us-east-2.amazonaws.com/dev/login";
```


## Step 2: Deploy Backend Services

```
terraform apply -var="frontend_domain=YOUR_CLOUDFRONT_DOMAIN" -auto-approve
```

This deploys:

- API Gateway
- Lambda
- DynamoDB
- IAM roles


---

# DynamoDB User Data

Insert items into your DynamoDB `user_data` table:

```
[
  {
    "username": "eyal",
    "password": "eyal",
    "paymentStatus": "paid",
    "expires": "2025-12-31"
  },
  {
    "username": "jackson",
    "password": "jackson",
    "paymentStatus": "expired",
    "expires": "2024-06-30"
  },
  {
    "username": "eyal",
    "password": "noy",
    "paymentStatus": "expired",
    "expires": "2024-06-30"
  }
]
```

### Expected Behavior

| Input | Expected |
|--------|----------|
| eyal / eyal | { "status": "Welcome" } |
| jackson / jackson | { "status": "payment expired" } |
| eyal / noy | { "status": "Invalid credentials" } |

---

# Password Hashing

cd ..
```
Install passlib:
```
python3 -m venv venv
```
source venv/bin/activate
```
pip3 install passlib
```
Generate a hash:
```
python3 hash.py
```

Paste results into DynamoDB instead of plain passwords.

---

# Testing

## Test CloudFront UI

```
https://YOUR_CLOUDFRONT_DOMAIN
```

## Test API Gateway Directly

```
curl -i -X POST "https://API_ID.execute-api.us-east-2.amazonaws.com/dev/login"   -H "Content-Type: application/json"   -d '{"username": "eyal", "password": "eyal"}'
```

## Test Lambda in Console

```
{
  "body": "{"username": "eyal", "password": "eyal"}"
}
```

---

# Troubleshooting

## 404 Not Found
Your route `/login` is not deployed to stage `dev`.

Check:

```
aws apigatewayv2 get-routes --api-id API_ID --region us-east-2
```

## 500 Internal Error
Common causes:
- Wrong environment variables
- DynamoDB table name mismatch
- Password hashing mismatch

## CloudFront returns 403
Not applicable for Option C API calls. Only affects static S3 files.




