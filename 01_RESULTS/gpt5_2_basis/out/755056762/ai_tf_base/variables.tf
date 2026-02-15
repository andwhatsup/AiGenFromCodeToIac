variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "etl-pipeline-project"
}

variable "s3_bucket_name" {
  description = "Optional fixed S3 bucket name. Leave null to auto-generate a globally-unique name."
  type        = string
  default     = null
}
