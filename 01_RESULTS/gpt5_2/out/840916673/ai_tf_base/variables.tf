variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "magic-color"
}

variable "bucket_force_destroy" {
  description = "Whether to force destroy the S3 bucket (useful for dev/test)"
  type        = bool
  default     = true
}
