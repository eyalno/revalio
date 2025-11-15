########################################
# DynamoDB Table: user_data
########################################

resource "aws_dynamodb_table" "user_data" {
  name         = "user_data"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "username"

  attribute {
    name = "username"
    type = "S"
  }

  table_class                   = "STANDARD"
  deletion_protection_enabled   = false
  stream_enabled                = false

  point_in_time_recovery {
    enabled = false
  }
}

########################################
# DynamoDB Item: one user record
########################################

resource "aws_dynamodb_table_item" "user_item" {
  depends_on = [
    aws_dynamodb_table.user_data
  ]

  table_name = aws_dynamodb_table.user_data.name
  hash_key   = "username"

  item = <<EOF
{
  "username":       { "S": "USER_NAME_HERE" },
  "password_hash":  { "S": "HASHED_PASSWORD_HERE" },
  "payment_status": { "S": "PAYMENT_STATUS_HERE" }
}
EOF
}

