
# Initialize to download the provider
terraform init


# Terraform Deployments. 2 Step :
  Step 1:
    deploy s3 bucket and cloud front first to avoid circular dependency 

    terraform apply \
      -target=aws_s3_bucket.static_site \
      -target=aws_s3_bucket_versioning.static_site_versioning \
      -target=aws_s3_bucket_server_side_encryption_configuration.static_site_sse \
      -target=aws_cloudfront_origin_access_control.oac \
      -target=aws_cloudfront_distribution.cdn 

  #update FrontEnd/script.js url with domain 
    const API_URL = "https://YOUR_CLOUDFRONT_DOMAIN/login";
    e.g cloudfront_domain = "d1aip92akmbkqu.cloudfront.net"

  Step 2:
    Deploy remaining resources
      terraform apply -var="frontend_domain=YOUR_CLOUDFRONT_DOMAIN"

# populate DynamoDB table
    
  Example content:

  [
    { # valid paid
      "username": "eyal",   
      "password": "eyal",
      "paymentStatus": "paid",
      "expires": "2025-12-31"
    },
    { # valid expired
      "username": "jackson",
      "password": "jackson",
      "paymentStatus": "expired",
      "expires": "2024-06-30"
    },
    { # invalid credentials 
      "username": "eyal",
      "password": "noy",
      "paymentStatus": "expired",
      "expires": "2024-06-30"
    }
  ]

  
  Input	Expected Response
  eyal / eyal	{ "status": "Welcome" }
  jackson / jackson	{ "status": "payment expired" }
  eyal / noy	{ "status": "Invalid credentials" }


  Password Hasing:
    pip3 install passlib
    python3 hash.py

  paste the hashed password to dynamoDB user_data table


# Testing
  Browse the cloudfront Domain and try different user/password combinations

# Troubleshoot different integration points:
  api_endpoint = "https://API_ENDPOINT.execute-api.us-east-2.amazonaws.com"
 curl -X POST https://API_ENDPOINT.execute-api.us-east-2.amazonaws.com/dev/login \
  -H "Content-Type: application/json" \
  -d '{"username": "eyal", "password": "eyal"}'

  Lambda Test Event:

    You can test directly in the AWS Lambda console:

    {
      "body": "{\"username\": \"eyal\", \"password\": \"eyal\"}"
    }


# Task 2: Serverless Web Application with Payment Check

This repository contains a small **static serverless web application** (in `FrontEnd/`) that demonstrates a simple login flow which checks a user's payment status stored in an **S3 object**.  

This README explains how to:
- Deploy the static site to Amazon S3 (optionally fronted by CloudFront)
- Format the user-data file
- Validate login credentials (client-side demo and secure server-side)
- Test the application via Lambda or API Gateway

---

## What This Task Requires

- Create a static serverless web app hosted on **S3** (optionally with **CloudFront**)
- Store a **user data file** in S3 containing `username`, `password`, and `paymentStatus`
- On login, the web app should:
  - Validate credentials against the file
  - If payment is expired, notify the user with a vanilla JavaScript popup
  - If valid and paid, show a welcome message or grant access

---

## Architecture Diagram




## Files in This Repository

| File | Description |
|------|--------------|
| `FrontEnd/index.html` | Example static UI |
| `FrontEnd/script.js` | Client-side login logic |
| `FrontEnd/style.css` | Styling for the web app |
| `terraform/login_handler.py` | Server-side Lambda to validate credentials securely |
| `hash.py` | Helper script for generating password hashes (requires `passlib`) |




