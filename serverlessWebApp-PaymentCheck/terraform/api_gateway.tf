############################
#  API Gateway v2: HTTP API
############################

resource "aws_apigatewayv2_api" "tst" {
  name          = "tst-1"
  protocol_type = "HTTP"

  cors_configuration {
    # For production, replace "*" with your CloudFront or Route53 domain
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

############################
#  Lambda Integration
############################

resource "aws_apigatewayv2_integration" "login_handler" {
  api_id                 = aws_apigatewayv2_api.tst.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.login_handler.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

############################
#  Route: OPTIONS /login
#  (Needed for CORS)
############################

resource "aws_apigatewayv2_route" "options_login" {
  api_id    = aws_apigatewayv2_api.tst.id
  route_key = "OPTIONS /login"
  target    = "integrations/${aws_apigatewayv2_integration.login_handler.id}"
}

############################
#  Route: POST /login
############################

resource "aws_apigatewayv2_route" "login_route" {
  api_id    = aws_apigatewayv2_api.tst.id
  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.login_handler.id}"
}

############################
#  Stage: dev (auto deploy)
############################

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.tst.id
  name        = "dev"
  auto_deploy = true
}