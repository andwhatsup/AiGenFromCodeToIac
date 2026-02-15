provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}
