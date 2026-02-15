variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "vault-fastapi-demo"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifact bucket (dangerous in production)."
  type        = bool
  default     = true
}
