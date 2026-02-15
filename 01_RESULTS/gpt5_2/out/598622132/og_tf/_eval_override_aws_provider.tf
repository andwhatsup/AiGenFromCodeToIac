# This is a provider override file that takes precedence over the main provider.tf
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    s3        = "http://localhost:4566"
    dynamodb  = "http://localhost:4566"
    iam       = "http://localhost:4566"
    sts       = "http://localhost:4566"
    kinesis   = "http://localhost:4566"
    lambda    = "http://localhost:4566"
    logs      = "http://localhost:4566"
    sns       = "http://localhost:4566"
    sqs       = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    # fixes / additions
    cloudwatch     = "http://localhost:4566"
    cloudwatchevents = "http://localhost:4566" # or: eventbridge = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    ecr            = "http://localhost:4566"
    ecrpublic      = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    efs            = "http://localhost:4566"
    route53        = "http://localhost:4566"
    kms            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    s3control      = "http://localhost:4566"
  }
}