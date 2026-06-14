project     = "infraforge"
environment = "prod"

aws_region = "us-east-2"

vpc_cidr = "10.2.0.0/16"

availability_zones = {
  az1 = "us-east-2a"
  az2 = "us-east-2b"
}

public_subnets = {
  az1 = "10.2.1.0/24"
  az2 = "10.2.2.0/24"
}

private_app_subnets = {
  az1 = "10.2.11.0/24"
  az2 = "10.2.12.0/24"
}

enable_nat_gateway = true

create_role             = true
create_instance_profile = true

role_name = "ec2-role-prod"

aws_managed_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
]

instance_name = "prod-web"

ami_id        = "ami-0c803b171269e2d72"
instance_type = "t3.small"

key_name = "infra-key"

public_subnet_az = "az1"

bucket_name = "infraforge-prod-app-data"

ingress_rules = [
  {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]