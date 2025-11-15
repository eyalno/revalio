#step 1


# terraform apply \
#   -target=aws_s3_bucket.static_site \
#   -target=aws_s3_bucket_versioning.static_site_versioning \
#   -target=aws_s3_bucket_server_side_encryption_configuration.static_site_sse \
#   -target=aws_cloudfront_origin_access_control.oac \
#   -target=aws_cloudfront_distribution.cdn \
#   -auto-approve

#update script.js url with domain 

#step 2

# terraform apply -var="frontend_domain=d3rzctrv66vn97.cloudfront.net" -auto-approve

variable "frontend_domain" {
  type = string
  default = ""
}