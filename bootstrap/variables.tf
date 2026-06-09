variable "aws_region" {
  description = "AWS region"

  type    = string
  default = "ap-south-1"
}

variable "bucket_name" {
  description = "Terraform state bucket name"

  type = string
}

variable "dynamodb_table_name" {
  description = "Terraform lock table"

  type = string
}