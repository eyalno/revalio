resource "aws_dynamodb_table" "usage_aggregates" {
  name         = "usage_aggregates_prod"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}