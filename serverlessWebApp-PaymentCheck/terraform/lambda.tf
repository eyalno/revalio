########################################
# Package Lambda from local Python file
########################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/login_handler.py"
  output_path = "${path.module}/login_handler.zip"
}

########################################
# Lambda Function: LoginHandler
########################################

resource "aws_lambda_function" "login_handler" {
  function_name = "LoginHandler"

  runtime       = "python3.12"
  handler       = "login_handler.login_handler"
  filename      = data.archive_file.lambda_zip.output_path
  package_type  = "Zip"
  architectures = ["x86_64"]

  role = "arn:aws:iam::997233416610:role/lambda"

  layers = [
    "arn:aws:lambda:us-east-2:997233416610:layer:passlib_layer:2"
  ]

  memory_size = 128
  timeout     = 3

  # Ensures Lambda is built before creation
  depends_on = [data.archive_file.lambda_zip]
}

########################################
# Allow API Gateway to invoke Lambda
########################################

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  function_name = aws_lambda_function.login_handler.function_name
  source_arn    = "${aws_apigatewayv2_api.tst.execution_arn}/*"
}