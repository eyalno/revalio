resource "aws_dynamodb_table" "usage_aggregates" {
  name         = "usage_aggregates_prod"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  # Strongly recommended for production tables
  point_in_time_recovery {
    enabled = true
  }

  # Optional but best practice for durability
  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = "prod"
    Service     = "usage-tracking"
  }
}