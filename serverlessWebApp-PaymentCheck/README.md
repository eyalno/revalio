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

## Architecture (Mermaid Diagram)

```mermaid
flowchart TD
  A[Client Browser] --> CF[CloudFront - OAC to S3 Static Site]
  CF --> S3Site[S3 Bucket - Static Site: index.html, JS, CSS]
  A --> APIGW[API Gateway - /login]
  APIGW --> L[Lambda Function - login_handler]
  L --> S3Data[S3 Bucket - Data: users.json]
  L --> A

## Files in This Repository

| File | Description |
|------|--------------|
| `FrontEnd/index.html` | Example static UI |
| `FrontEnd/script.js` | Client-side login logic |
| `FrontEnd/style.css` | Styling for the web app |
| `lambda_function.py` | Server-side Lambda to validate credentials securely |
| `hash.py` | Helper script for generating password hashes (requires `passlib`) |

To install the hashing dependency:
```bash
pip3 install passlib


⸻-

Sample User Data File (S3 Object)

File name: users.json

Example content:

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

⚠️ Security Tip: In a production setup, store password hashes (e.g., bcrypt) instead of plaintext passwords.

⸻

Testing

CloudFront (Static Frontend)

https://d3hsdedk703oiv.cloudfront.net

Expected Responses

Input	Expected Response
eyal / eyal	{ "status": "Welcome" }
jackson / jackson	{ "status": "payment expired" }
eyal / noy	{ "status": "Invalid credentials" }


⸻

Lambda Test Event

You can test directly in the AWS Lambda console:

{
  "body": "{\"username\": \"eyal\", \"password\": \"eyal\"}"
}


⸻

API Gateway Test via cURL

curl -X POST https://yuedw9yzch.execute-api.us-east-2.amazonaws.com/dev/login \
  -H "Content-Type: application/json" \
  -d '{"username": "eyal", "password": "eyal"}'


⸻

Security Notes
	•	Never return passwords or sensitive data in responses.
	•	Always use HTTPS (API Gateway provides HTTPS by default).
	•	Use IAM policies to restrict S3 access to Lambda only.
	•	For production, hash passwords and store them securely.

⸻
