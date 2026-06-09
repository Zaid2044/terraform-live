data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "zaid-terraform-state-2044"
    key    = "vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "web_sg" {
  source = "git::https://github.com/Zaid2044/terraform-aws-security-group.git?ref=v1.0.0"

  project     = "platform"
  environment = "dev"

  name = "web"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "All outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}