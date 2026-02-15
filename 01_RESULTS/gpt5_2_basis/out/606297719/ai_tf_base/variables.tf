variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for created resources"
  type        = string
  default     = "prefect-agent"
}

variable "s3_bucket_name" {
  description = "Optional fixed name for the S3 bucket used for Prefect flow storage/artifacts. Leave null to auto-generate."
  type        = string
  default     = null
}
