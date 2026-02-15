variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}
