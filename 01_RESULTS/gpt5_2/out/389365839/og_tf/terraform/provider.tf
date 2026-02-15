terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "mehlj-ecs-tfstate"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mehljecs_state_locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  # helps track project-specific costs
  default_tags {
    tags = {
      Name = "mehlj-pipeline"
    }
  }
}