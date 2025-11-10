## Task 2: Serverless Web Application with Payment Check

This repository contains a small static serverless web application (in `FrontEnd/`) that demonstrates a simple login flow which checks a user's payment status stored in an S3 object. This README explains how to deploy the static site to Amazon S3 (optionally fronted by CloudFront), how the user-data file should be formatted, how login validation can work (client-side demo and secure server-side approach), and provides example AWS CLI commands and policies.

## What this task requires

- Create a static serverless web app hosted on S3 (optionally with CloudFront).
- Store a user data file in S3 containing username, password and payment status.
- On login the web app should:
  - validate credentials against the file;
  - if payment is expired, notify the user via a vanilla JavaScript popup;
  - if valid and paid, show a welcome message / grant access.

## Architecture schema
+------------------+                     +----------------------------+
|      Client      |  HTTPS (GET)        |        CloudFront          |
|  Browser (JS)    +-------------------->+   OAC to S3 Static Site    |
+---------+--------+                     +--------------+-------------+
          |                                               |
          |                                               | OAC
          |                                               v
          |                                    +----------------------+
          |                                    |   S3 Bucket (Site)   |
          |                                    |  index.html, JS, CSS |
          |                                    +----------------------+
          |
          | HTTPS (POST /login)
          v
+------------------+          IAM auth          +----------------------+
|   API Gateway    +---------------------------> |      Lambda          |
|  Route: /login   |                            |   login_handler      |
+---------+--------+                            +----------+-----------+
          |                                                |
          |                          s3:GetObject          |
          |                                                v
          |                                     +----------------------+
          |                                     |  S3 Bucket (Data)    |
          |                                     |   users.json (hashed |
          |                                     |   passwords, status) |
          |                                     +----------------------+
          |
          |  JSON {ok | expired | invalid}
          +-------------------------------- back to Client


Files included in this repo:

- `FrontEnd/index.html` — example static UI.
- `FrontEnd/script.js` — client-side behavior (login flow).
- `FrontEnd/style.css` — styling.
- `lambda_function.py` —  server-side example to validate credentials securely.
- `hash.py` — small helper (if you wish to hash/passwords locally for demo).
    For hash.py - pip3 install passlib

## Sample user-data file (S3 object)

Example content:
```json
  {
    "username": "eyal",
    "password": "eyal",
    "paymentStatus": "paid",
    "expires": "2025-12-31"
  }


## Testing 
cloud front URL - Static web app (frontend)::
  https://d3hsdedk703oiv.cloudfront.net

Input               Expected Response

eyal / eyal         { "status": "Welcome" }

jackson / jackson   { "status": "payment expired" }

eyal / noy          { "status": "Invalid credentials" }


Lambda Test Event
{
  "body": "{\"username\": \"eyal\", \"password\": \"eyal\"}"
}

API Gateway Test via cURL
curl -X POST https://yuedw9yzch.execute-api.us-east-2.amazonaws.com/dev/login \
-H "Content-Type: application/json" \
-d '{"username": "eyal", "password": "eyal"}'

Security notes:
- Never return password fields in responses.
- Use HTTPS (API Gateway has HTTPS by default).













