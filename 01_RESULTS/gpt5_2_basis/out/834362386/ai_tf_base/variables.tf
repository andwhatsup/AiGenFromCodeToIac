variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "vat-calc"
}

variable "bucket_force_destroy" {
  description = "Whether to force-destroy the S3 bucket (dangerous)."
  type        = bool
  default     = false
}
