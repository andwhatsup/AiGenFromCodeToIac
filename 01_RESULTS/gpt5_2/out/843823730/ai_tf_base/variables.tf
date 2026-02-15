variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "notes-keeper"
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name. Leave null to have Terraform generate one."
  type        = string
  default     = null
}
