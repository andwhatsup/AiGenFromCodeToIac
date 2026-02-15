variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "nodejsapp"
}

variable "bucket_force_destroy" {
  description = "Whether to force-destroy the artifacts bucket (dangerous in production)."
  type        = bool
  default     = true
}
