module "ec2_role" {
  source = "git::https://github.com/Zaid2044/terraform-aws-iam-role.git?ref=v1.0.0"

  project     = "platform"
  environment = "dev"

  role_name = "ec2"

  service_principal = "ec2.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}