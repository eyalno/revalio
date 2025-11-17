########################################
# API Outputs
########################################

output "api_url" {
  description = "Base URL for the Usage Tracking API"
  value       = aws_apigatewayv2_api.usage_api.api_endpoint
}

########################################
# Database Outputs
########################################

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.usage_db.address
}

########################################
# DynamoDB Outputs
########################################

output "ddb_table" {
  description = "Name of the DynamoDB usage aggregates table"
  value       = aws_dynamodb_table.usage_aggregates.name
}