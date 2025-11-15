# resource "aws_iam_role" "lambda_role" {
#   name = "lambda-basic-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_iam_policy" "lambda_dynamodb_policy" {
#   name = "lambda-dynamodb-access"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "dynamodb:GetItem",
#           "dynamodb:Query",
#           "dynamodb:Scan"
#         ]
#         Resource = "arn:aws:dynamodb:us-east-2:${data.aws_caller_identity.current.account_id}:table/user_data"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
# }