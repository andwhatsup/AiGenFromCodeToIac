variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application/name prefix used for tagging and resource naming."
  type        = string
  default     = "rancher-cluster"
}
