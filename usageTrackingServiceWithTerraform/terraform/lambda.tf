#############################################
# ZIP PACKAGING
#############################################

data "archive_file" "init_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_init_src"
  output_path = "${path.module}/lambda_init.zip"
}

data "archive_file" "main_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_main.zip"
}


#############################################
# PG8000 LAYER (UPLOAD YOUR ZIP FIRST)
#############################################

resource "aws_lambda_layer_version" "pg8000" {
  filename   = "${path.module}/lambda_layer/pg8000_layer.zip"
  layer_name = "pg8000-layer"
  compatible_runtimes = ["python3.12"]
}


#############################################
# INIT DB LAMBDA (RUNS ONCE)
#############################################

resource "aws_lambda_function" "init_db" {
  function_name = "InitDB-Lambda"
  role          = "arn:aws:iam::997233416610:role/usage-tracking-prod-lambda-role"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.init_zip.output_path
  source_code_hash = data.archive_file.init_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = [aws_lambda_layer_version.pg8000.arn]

  environment {
    variables = {
      DB_HOST     = aws_db_instance.usage_db.address
      DB_PORT     = "5432"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }

  timeout     = 10
  memory_size = 128
}


#############################################
# RUN INIT LAMBDA ONCE
#############################################

resource "aws_lambda_invocation" "run_init" {
  function_name = aws_lambda_function.init_db.function_name
  input         = "{}"

  depends_on = [
    aws_lambda_function.init_db,
    aws_db_instance.usage_db
  ]
}


#############################################
# MAIN USAGE HANDLER
#############################################

resource "aws_lambda_function" "usage_handler" {
  function_name = "UsageHandlerProd"
  role          = "arn:aws:iam::997233416610:role/usage-tracking-prod-lambda-role"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.main_zip.output_path
  source_code_hash = data.archive_file.main_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = [aws_lambda_layer_version.pg8000.arn]

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

  depends_on = [aws_lambda_invocation.run_init]
}