variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = map(string)
}

variable "public_subnets" {
  type = map(string)
}

variable "private_app_subnets" {
  type = map(string)
}

variable "enable_nat_gateway" {
  type = bool
}

variable "create_role" {
  type = bool
}

variable "create_instance_profile" {
  type = bool
}

variable "role_name" {
  type = string
}

variable "aws_managed_policy_arns" {
  type = list(string)
}

variable "instance_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_subnet_az" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}