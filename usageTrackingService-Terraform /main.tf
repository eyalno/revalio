

provider "aws" {
  region = "us-east-2"
}


resource "aws_dynamodb_table" "usage_aggregates" {
  name           = "usage_aggregates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "username"

  attribute {
    name = "username"
    type = "S"
  }

  attribute {
    name = "total_usage"
    type = "N"
  }

  attribute {
    name = "event_count"
    type = "N"
  }
}




# ----------------------------
# 1. Define a sensitive variable for the DB password
# ----------------------------
variable "db_password" {
  type      = string
  sensitive = true
}

# ----------------------------
# 2. Create a Secrets Manager secret
# ----------------------------
resource "aws_secretsmanager_secret" "db_password" {
  name = "usage_db_password"
}

# ----------------------------
# 3. Store the password in the secret (from the variable, not hardcoded)
# ----------------------------
resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = var.db_password })
}

resource "aws_db_instance" "usage_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = "usage_db"
  username             = "admin"
  password             = var.db_password 
  skip_final_snapshot  = true
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}