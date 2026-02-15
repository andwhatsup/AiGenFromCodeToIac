variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming/tagging."
  type        = string
  default     = "vault-fastapi-demo"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifacts bucket (dangerous)."
  type        = bool
  default     = false
}
