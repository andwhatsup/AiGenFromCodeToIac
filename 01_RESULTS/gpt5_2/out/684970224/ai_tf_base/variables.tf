variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application/name prefix used for resource naming."
  type        = string
  default     = "oci-helm-chart-metadata"
}
