# terraform apply \
#   -target=aws_dynamodb_table.user_data \
#   -target=aws_dynamodb_table_item.user_item \
#   -auto-approve
  
#   terraform destroy \
#   -target=aws_dynamodb_table.user_data \
#   -target=aws_dynamodb_table_item.user_item \
#   -auto-approve

  resource "aws_dynamodb_table" "user_data" {
    attribute {
      name = "username"
      type = "S"
    }

    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = "false"
    hash_key                    = "username"
    name                        = "user_data"

  point_in_time_recovery {
    enabled = false
  }
    stream_enabled = "false"
    table_class    = "STANDARD"
  }

  # Insert 1 item with 3 attributes
  resource "aws_dynamodb_table_item" "user_item" {
   depends_on = [
    aws_dynamodb_table.user_data
  ]
    table_name = aws_dynamodb_table.user_data.name
    hash_key   = "username"

    item = <<EOF
  {
    "username": { "S": "USER_NAME_HERE" },
    "password_hash": { "S": "HASHED_PASSWORD_HERE" },
    "payment_status": { "S": "PAYMENT_STATUS_HERE" }
  }
  EOF
  }


  output "aws_dynamodb_table_user_data_id" {
    value = "${aws_dynamodb_table.user_data.id}"
  }
