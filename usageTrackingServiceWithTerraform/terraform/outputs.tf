output "api_url" {
  value = aws_apigatewayv2_api.usage_api.api_endpoint
}

output "db_endpoint" {
  value = aws_db_instance.usage_db.address
}

output "ddb_table" {
  value = aws_dynamodb_table.usage_aggregates.name
}