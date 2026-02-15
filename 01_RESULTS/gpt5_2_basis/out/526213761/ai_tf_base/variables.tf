variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-2"
}

variable "app_name" {
  description = "Application name used for resource naming and tagging."
  type        = string
  default     = "flink-poc"
}

variable "artifact_bucket_name" {
  description = "Optional explicit S3 bucket name for artifacts/checkpoints. Leave null to auto-generate."
  type        = string
  default     = null
}
