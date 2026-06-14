output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "role_arn" {
  value = module.iam.role_arn
}
