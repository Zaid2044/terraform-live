terraform {
  backend "s3" {
    bucket         = "infraforge-tf-state"
    key            = "stage/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "infraforge-tf-locks"
    encrypt        = true
  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}