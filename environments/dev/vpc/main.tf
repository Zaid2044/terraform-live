module "vpc" {
  source = "git::https://github.com/Zaid2044/terraform-aws-vpc.git?ref=v1.0.0"

  project     = "platform"
  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = {
    a = "ap-south-1a"
    b = "ap-south-1b"
  }

  public_subnets = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }

  private_app_subnets = {
    a = "10.0.11.0/24"
    b = "10.0.12.0/24"
  }

  private_db_subnets = {
    a = "10.0.21.0/24"
    b = "10.0.22.0/24"
  }
}