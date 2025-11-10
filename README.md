Revailo — AWS Developer Coding Test
Date: 10/17/2025

Overview
--------
This repository contains a three-part developer exercise demonstrating a small Python
client that integrates with ChatGPT, a serverless static web app that checks payment
status, and Terraform-managed infrastructure for a usage-tracking service.

Tasks
-----

1) Python Client for ChatGPT
   - Create a Python program that accepts a ChatGPT API token and a PDF file.
   - Upload the PDF to the ChatGPT API and run a multi-turn conversation about the
     document's contents.
   - Print ChatGPT responses to the console for easy review.

2) Serverless Web Application with Payment Check
   - A static single-page web app (HTML + vanilla JS + CSS) designed to be hosted on
     Amazon S3 (CloudFront optional).
   - Store a simple user data file (JSON) in S3 with entries: username, password, payment
     status.
   - On login, the app should validate credentials against the file and:
     - Show a vanilla JavaScript popup if payment is expired.
     - Show a welcome message or grant access if payment is valid.

3) Usage Tracking Service (Terraform)
   - Use Terraform to provision an API (API Gateway) that routes to Lambda(s). Persistence
     is handled by RDS (events) and DynamoDB (per-user aggregates).
   - Lambda endpoints:
     - POST /usage — accept a user's usage time, write an event to RDS, update per-user
       aggregates in DynamoDB, and return a response.
     - GET /stats/average — return the average usage time across all users.

Provided Resources
------------------
- Sandbox AWS account access (with sufficient permissions for the exercise).
- ChatGPT API token (for Task 1).

Deliverables
------------
- Terraform code for the infrastructure (modular and reusable).
- Source code for Lambda(s), the web app (HTML/JS/CSS), and the Python ChatGPT client.
- README files and short demo notes showing how to deploy and test the solution.

Repository Layout (top-level)
----------------------------
- `pythonClientForChatGpt/` — Python client and docs
- `serverlessWebApp-PaymentCheck/` — static web app and Lambda examples
- `usageTrackingService-Terraform/` — Terraform code and Lambda implementations

