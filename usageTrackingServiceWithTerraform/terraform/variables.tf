########################################
# Region
########################################

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

########################################
# Database Credentials
########################################

variable "db_username" {
  description = "Master username for the RDS PostgreSQL instance"
  type        = string
  sensitive   = true
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the RDS PostgreSQL instance"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME"   # Do not keep real secrets here
}

variable "db_name" {
  description = "Initial database name to create"
  type        = string
  default     = "usage_tracking"
}