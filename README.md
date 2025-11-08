# Project Name

## Overview
This project demonstrates a serverless application using AWS Lambda, DynamoDB, and API Gateway with a web front-end and a Python client for testing.

---

## Folder Structure
```
project-root/
├── terraform/        # Infrastructure as code
├── lambda/           # AWS Lambda functions
├── webapp/           # Front-end (HTML, JS, CSS)
├── python-client/    # Python client for testing/demo
└── demo/             # Screenshots or demo video
```

---

## Prerequisites
- [Terraform](https://www.terraform.io/downloads)
- AWS CLI configured with appropriate credentials
- Python 3.x
- Node.js/npm (if running front-end locally)

---

## Deployment Instructions

### 1. Terraform Infrastructure
1. Navigate to the Terraform folder:
   ```bash
   cd terraform
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the deployment:
   ```bash
   terraform plan -var-file=envs/dev.tfvars
   ```
4. Apply the infrastructure:
   ```bash
   terraform apply -var-file=envs/dev.tfvars
   ```

### 2. Deploy Lambda Functions
- Each Lambda folder contains `lambda_function.py` and `requirements.txt`.
- Install dependencies and package for deployment if required.
- Deploy via Terraform or AWS Console (Terraform modules can handle this).

### 3. Front-End Web App
- Open `webapp/index.html` in a browser.
- Update `app.js` with your API endpoint from Terraform outputs.

### 4. Python Client
1. Install dependencies:
   ```bash
   pip install -r python-client/requirements.txt
   ```
2. Run the client:
   ```bash
   python python-client/client.py
   ```
3. The client will interact with your deployed API.

---

## Testing & Demo
- Use the Python client or the web app to verify functionality.
- Refer to the `demo/` folder for screenshots or a demo video.

---

## Notes
- Terraform modules are reusable for deploying additional Lambda functions or DynamoDB tables.
- For production deployment, update `envs/prod.tfvars` and apply accordingly.
