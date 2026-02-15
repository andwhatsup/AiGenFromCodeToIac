variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "boxjump-game"
}

variable "bucket_force_destroy" {
  description = "Whether to allow Terraform to destroy the S3 bucket even if it contains objects"
  type        = bool
  default     = true
}
