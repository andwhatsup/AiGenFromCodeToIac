terraform {
  backend "s3" {
    bucket = "your-s3-bucket"
    key    = "high-frequency-flambda/state"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

module "hflambda" {
  source = "github.com/rockset/high-frequency-lambda"
  providers = {
    aws = aws.us-west-2
  }
  target_lambda = "arn of the lambda you want to invoke"
}
