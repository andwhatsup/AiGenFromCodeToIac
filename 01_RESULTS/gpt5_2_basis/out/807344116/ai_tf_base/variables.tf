variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for created resources"
  type        = string
  default     = "epicac"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifact bucket (useful for ephemeral/dev environments)"
  type        = bool
  default     = true
}
