data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "zaid-terraform-state-2044"
    key    = "vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket = "zaid-terraform-state-2044"
    key    = "sg/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "zaid-terraform-state-2044"
    key    = "iam/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "ec2" {
  source = "git::https://github.com/Zaid2044/terraform-aws-ec2.git?ref=v1.0.0"

  project     = "platform"
  environment = "dev"

  name = "web"

  instance_count = 2

  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids["a"]

  security_group_ids = [
    data.terraform_remote_state.sg.outputs.security_group_id
  ]

  instance_profile_name = data.terraform_remote_state.iam.outputs.instance_profile_name

  root_volume_size = 20

  user_data = <<-EOF
#!/bin/bash
dnf update -y
EOF

  tags = {
    Application = "web"
  }
}