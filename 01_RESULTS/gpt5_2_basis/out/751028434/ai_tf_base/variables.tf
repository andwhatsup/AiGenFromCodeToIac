variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "A short name used for tagging and resource naming."
  type        = string
  default     = "nebari-metrics-server-plugin"
}

variable "artifact_bucket_name" {
  description = "Optional explicit S3 bucket name for build artifacts (leave null to let Terraform generate)."
  type        = string
  default     = null
}
