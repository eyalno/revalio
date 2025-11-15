output "frontend_origin" {
  value = aws_cloudfront_distribution.cdn.domain_name
}



output "api_id" {
  value = aws_apigatewayv2_api.tst.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.tst.api_endpoint
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.tst.execution_arn
}

# output "login_route_id" {
#   value = aws_apigatewayv2_route.login_route.id
# }

# output "login_integration_id" {
#   value = aws_apigatewayv2_integration.login_handler.id
# }

output "dev_stage_url" {
  value = "https://${aws_apigatewayv2_api.tst.api_endpoint}/dev"
}



output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}






output "lambda_name" {
  value = aws_lambda_function.login_handler.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.login_handler.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.login_handler.invoke_arn
}

output "lambda_zip_path" {
  value = data.archive_file.lambda_zip.output_path
}




output "bucket_id" {
  value = aws_s3_bucket.static_site.id  
}

output "bucket_arn" {
  value = aws_s3_bucket.static_site.arn
}

output "bucket_policy_id" {
  value = aws_s3_bucket_policy.static_site.id
}