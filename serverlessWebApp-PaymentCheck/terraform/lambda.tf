# terraform apply \
#   -target=data.archive_file.lambda_zip \
#   -target=aws_lambda_function.login_handler \
#   -target=aws_lambda_permission.api_invoke \
#   -auto-approve \
#   -profile=revalio

# terraform destroy \
#   -target=aws_lambda_function.login_handler \
#   -target=aws_lambda_permission.api_invoke \
#   -auto-approve
#   -profile=revalio

resource "aws_lambda_function" "login_handler" {
  function_name = "LoginHandler"

  role          = "arn:aws:iam::997233416610:role/lambda"
  handler       = "login_handler.login_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/login_handler.zip"
  package_type  = "Zip"

  layers = [
    "arn:aws:lambda:us-east-2:997233416610:layer:passlib_layer:2"
  ]
  depends_on = [data.archive_file.lambda_zip]
  architectures = ["x86_64"]
  memory_size   = 128
  timeout       = 3
}


resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.tst.execution_arn}/*"
}

# zip -r login_handler.zip lambda_function.py

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/login_handler.py"
  output_path = "${path.module}/login_handler.zip"
}

