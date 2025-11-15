########################################
# OPTIONAL: destroy-only targets you added earlier
########################################
# terraform apply \
#   -target=aws_s3_bucket.static_site \
#   -target=aws_s3_bucket_versioning.static_site_versioning \
#   -target=aws_s3_bucket_server_side_encryption_configuration.static_site_sse \
#   -target=aws_s3_object.frontend_files \
#   -auto-approve


#
# terraform destroy \
#   -target=aws_s3_object.frontend_files \
#   -target=aws_s3_bucket_policy.static_site \
#   -target=aws_s3_bucket_server_side_encryption_configuration.static_site_sse \
#   -target=aws_s3_bucket_versioning.static_site_versioning \
#   -auto-approve









resource "aws_s3_bucket" "static_site" {
  bucket        = "demo-bucket-revalio"
  force_destroy = false

  object_lock_enabled = false
}


resource "aws_s3_bucket_versioning" "static_site_versioning" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status     = "Suspended"   # or "Enabled"
    mfa_delete = "Disabled"    # or "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_site_sse" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}


########################################
# Upload FRONTEND FILES
########################################

locals {
  frontend_dir = "${path.module}/../FrontEnd"

  # Upload all files EXCEPT hidden files (starting with ".")
  upload_files = [
    for f in fileset(local.frontend_dir, "**") :
    f if !startswith(basename(f), ".")
  ]
}


########################################
# Upload all frontend files (HTML, CSS, JS, etc)
########################################

resource "aws_s3_object" "frontend_files" {
  for_each = { for f in local.upload_files : f => f }

  bucket = aws_s3_bucket.static_site.id
  key    = each.value
  source = "${local.frontend_dir}/${each.value}"
  etag   = filemd5("${local.frontend_dir}/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "json" = "application/json"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}



########################################
# S3 Bucket Policy for OAC access
########################################

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontOACRead",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.static_site.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn"     = aws_cloudfront_distribution.cdn.arn,
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}