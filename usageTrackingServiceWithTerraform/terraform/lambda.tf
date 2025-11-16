
resource "aws_lambda_function" "usage_handler" {
  function_name = "UsageHandlerProd-tf"
  role          = "arn:aws:iam::997233416610:role/usage-tracking-prod-lambda-role"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/usage_handler.zip"
  source_code_hash = filebase64sha256("${path.module}/usage_handler.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.usage_aggregates.name
      DB_HOST        = aws_db_instance.usage_db.address
      DB_PORT        = "5432"
      DB_USER        = var.db_username
      DB_PASSWORD    = var.db_password
      DB_NAME        = var.db_name
    }
  }

  timeout     = 10
  memory_size = 256
  architectures = ["x86_64"]
}