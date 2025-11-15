# terraform apply \
#   -target=aws_apigatewayv2_api.api \
#   -target=aws_apigatewayv2_integration.login_handler \
#   -target=aws_apigatewayv2_route.login_route \
#   -target=aws_apigatewayv2_stage.dev \
#   -target=aws_lambda_permission.allow_apigw \
#   -auto-approve


# terraform destroy \
#   -target=aws_apigatewayv2_route.login_route \
#   -target=aws_apigatewayv2_integration.login_handler \
#   -target=aws_apigatewayv2_stage.dev \
#   -target=aws_apigatewayv2_api.api \
#   -target=aws_lambda_permission.allow_apigw \
#   -auto-approve


############################
#  Lambda (existing)
############################
# IMPORTANT:
# Replace this with your actual Lambda resource OR import the Lambda ARN.
# This data source allows us to reference the existing Lambda.
# data "aws_lambda_function" "login" {
#   function_name = "LoginHandler"
# }

############################
#  API Gateway v2 HTTP API
############################
resource "aws_apigatewayv2_api" "tst" {
  name          = "tst-1"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]  # allow_origins = ["https://${var.frontend_domain}"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_route" "options_login" {
  api_id    = aws_apigatewayv2_api.tst.id
  route_key = "OPTIONS /login"
  target    = "integrations/${aws_apigatewayv2_integration.login_handler.id}"
}

############################
#  Lambda Integration
############################

resource "aws_apigatewayv2_integration" "login_handler" {
  api_id                 = aws_apigatewayv2_api.tst.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.login_handler.invoke_arn
  payload_format_version = "2.0"
  integration_method     = "POST"
}

############################
#  Route:  POST /login
############################

resource "aws_apigatewayv2_route" "login_route" {
  api_id    = aws_apigatewayv2_api.tst.id
  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.login_handler.id}"
}

############################
#  Stage: dev  (auto deploy)
############################

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.tst.id
  name        = "dev"
  auto_deploy = true
}


