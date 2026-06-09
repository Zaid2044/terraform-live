terraform {
  backend "s3" {
    bucket         = "zaid-terraform-state-2044"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}