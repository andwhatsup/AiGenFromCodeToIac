provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway           = var.aws_endpoint
    cloudwatch           = var.aws_endpoint
    dynamodb             = var.aws_endpoint
    ec2                  = var.aws_endpoint
    ecr                  = var.aws_endpoint
    ecs                  = var.aws_endpoint
    elasticloadbalancing = var.aws_endpoint
    iam                  = var.aws_endpoint
    logs                 = var.aws_endpoint
    s3                   = var.aws_endpoint
    ssm                  = var.aws_endpoint
    sts                  = var.aws_endpoint
  }

  default_tags {
    tags = {
      Project = var.app_name
      Managed = "terraform"
    }
  }
}
