########################################
# Terraform Settings
########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

########################################
# AWS Provider
########################################

provider "aws" {
  region  = "us-east-2"
  profile = "revalio"
}

########################################
# Local Variables
########################################

locals {
  # In prod, replace with CloudFront domain:
  # frontend_domain = aws_cloudfront_distribution.cdn.domain_name

  frontend_domain = "*"
}