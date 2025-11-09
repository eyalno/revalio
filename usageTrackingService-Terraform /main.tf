

provider "aws" {
  region = "us-east-2"
  profile = "default"
}


resource "aws_dynamodb_table" "usage_aggregates" {
  name           = "usage_aggregates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "username"

  attribute {
    name = "username"
    type = "S"
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
  engine_version       = "11.22-rds.20241121"
  instance_class       = "db.t3.micro"
  db_name              = "usage_db"
  username             = "usage_admin"
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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "usage_tracker" {
  function_name = "usage_tracker"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function.zip"

  layers = [aws_lambda_layer_version.deps_layer.arn]

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.usage_aggregates.name
      RDS_HOST     = aws_db_instance.usage_db.address
      RDS_USER     = "admin"
      RDS_PASSWORD = var.db_password
      RDS_DB       = "usage_db"
    }
  }
}

resource "aws_apigatewayv2_api" "usage_api" {
  name          = "usage-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.usage_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.usage_tracker.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_usage" {
  api_id    = aws_apigatewayv2_api.usage_api.id
  route_key = "POST /usage"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_average" {
  api_id    = aws_apigatewayv2_api.usage_api.id
  route_key = "GET /stats/average"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.usage_tracker.function_name
  principal     = "apigateway.amazonaws.com"
}


output "api_endpoint" {
  value = aws_apigatewayv2_api.usage_api.api_endpoint
}

output "dynamodb_table" {
  value = aws_dynamodb_table.usage_aggregates.name
}

output "rds_endpoint" {
  value = aws_db_instance.usage_db.address
}

resource "aws_lambda_layer_version" "deps_layer" {
  layer_name  = "lambda_dependencies"
  filename    = "lambda_layer.zip"
  compatible_runtimes = ["python3.11"]
  description = "Common dependencies for usage Lambda"
}