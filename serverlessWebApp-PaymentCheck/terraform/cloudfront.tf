########################################
# CloudFront Managed Policies
########################################

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

########################################
# Origin Access Control (OAC) for S3
########################################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "revalio-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################################
# CloudFront Distribution
########################################

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  comment             = "Revalio static site CDN"
  default_root_object = "index.html"

  ########################################
  # Origin 1: S3 Static Website
  ########################################
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  ########################################
  # Origin 2: API Gateway
  ########################################
  origin {
    # API Gateway endpoint requires stripping "https://"
    domain_name = replace(aws_apigatewayv2_api.tst.api_endpoint, "https://", "")
    origin_id   = "api-origin"
    origin_path = "/dev"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ########################################
  # /login → API Gateway (no caching)
  ########################################
  ordered_cache_behavior {
    path_pattern           = "/login*"
    target_origin_id       = "api-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
  }

  ########################################
  # Default: Serve static files from S3
  ########################################
  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    # AWS Managed-CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  ########################################
  # Other distribution settings
  ########################################

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}