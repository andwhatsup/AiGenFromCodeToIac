variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "wd-prediction"
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name for static site hosting. Leave null to auto-generate."
  type        = string
  default     = null
}
