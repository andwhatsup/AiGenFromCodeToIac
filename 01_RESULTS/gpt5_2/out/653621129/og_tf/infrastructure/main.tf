terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

data "aws_availability_zones" "available" {}

locals {
  default_tags = {
    "Managed-By" : "Terraform",
    "Stack" : var.name,
    "Environment" : "dev"
  }

  final_tags = merge(local.default_tags, var.tags)

  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

#tfsec:ignore:aws-ec2-no-public-ingress-acl
#tfsec:ignore:aws-ec2-no-excessive-port-access
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.name}-vpc"

  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k + 8)]

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true

  tags = local.final_tags

}

module "compute" {
  source = "./compute"

  name = var.name

  vpc                 = module.vpc.vpc_id
  vpc_public_subnets  = module.vpc.public_subnets
  vpc_private_subnets = module.vpc.private_subnets
  image_name          = var.image_name

  tags = local.final_tags
}