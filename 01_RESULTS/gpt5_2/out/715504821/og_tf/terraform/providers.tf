provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

terraform {
  backend "s3" {
    bucket  = "developement-tf-state"
    key     = "tla-example/dev_plan.tfstate"
    region  = "eu-west-2" # Set your desired region
    encrypt = true
  }
}