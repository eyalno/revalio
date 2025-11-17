########################################
# API Gateway (HTTP API)
########################################
resource "aws_apigatewayv2_api" "usage_api" {
  name          = "usage-tracking-api-tf"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

########################################
# Lambda Integration
########################################
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.usage_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.usage_handler.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

########################################
# Routes
########################################

# POST /usage
resource "aws_apigatewayv2_route" "post_usage" {
  api_id    = aws_apigatewayv2_api.usage_api.id
  route_key = "POST /usage"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# GET /stats/average
resource "aws_apigatewayv2_route" "get_avg" {
  api_id    = aws_apigatewayv2_api.usage_api.id
  route_key = "GET /stats/average"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

########################################
# Stage ($default)
########################################
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.usage_api.id
  name        = "$default"
  auto_deploy = true
}

########################################
# Lambda Permission for API Gateway
########################################
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.usage_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.usage_api.execution_arn}/*/*"
}