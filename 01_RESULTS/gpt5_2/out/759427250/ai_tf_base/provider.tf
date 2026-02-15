provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_access_key_id
  secret_key                  = var.aws_secret_access_key
  skip_credentials_validation = var.skip_credentials_validation
  skip_metadata_api_check     = var.skip_metadata_api_check
  skip_requesting_account_id  = var.skip_requesting_account_id

  s3_use_path_style = var.s3_use_path_style

  endpoints {
    apigateway           = var.aws_endpoint
    cloudwatch           = var.aws_endpoint
    dynamodb             = var.aws_endpoint
    ec2                  = var.aws_endpoint
    ecr                  = var.aws_endpoint
    ecs                  = var.aws_endpoint
    elasticloadbalancing = var.aws_endpoint
    iam                  = var.aws_endpoint
    kms                  = var.aws_endpoint
    logs                 = var.aws_endpoint
    s3                   = var.aws_endpoint
    secretsmanager       = var.aws_endpoint
    sns                  = var.aws_endpoint
    sqs                  = var.aws_endpoint
    sts                  = var.aws_endpoint
  }

  default_tags {
    tags = {
      Project = var.app_name
      Managed = "terraform"
    }
  }
}
