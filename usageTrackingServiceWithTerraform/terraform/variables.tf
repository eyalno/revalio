

# i wasn't able to create secret manager 

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "db_username" {
  type      = string
  sensitive = true
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
  default = "cezkuR-pebgox-jozwi5tf"
}

variable "db_name" {
  type    = string
  default = "usage_tracking"
}