module "vpc" {
  source = "git::https://github.com/Zaid2044/terraform-aws-vpc.git?ref=v2.0.0"

  project     = var.project
  environment = var.environment

  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_app_subnets = var.private_app_subnets

  enable_nat_gateway = var.enable_nat_gateway
}

module "iam" {
  source = "git::https://github.com/Zaid2044/terraform-aws-iam-role.git?ref=v2.0.0"

  project     = var.project
  environment = var.environment

  create_role             = var.create_role
  create_instance_profile = var.create_instance_profile

  role_name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  aws_managed_policy_arns = var.aws_managed_policy_arns
}

module "ec2" {
  source = "git::https://github.com/Zaid2044/terraform-aws-ec2.git?ref=v2.0.0"

  project     = var.project
  environment = var.environment

  instance_name = var.instance_name

  ami_id        = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[var.public_subnet_az]

  instance_profile_name = module.iam.instance_profile_name

  ingress_rules = var.ingress_rules
}

module "s3" {
  source = "git::https://github.com/Zaid2044/terraform-aws-s3.git?ref=v1.0.0"

  project     = var.project
  environment = var.environment

  bucket_name = var.bucket_name
}