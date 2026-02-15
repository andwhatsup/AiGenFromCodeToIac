variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming and tagging."
  type        = string
  default     = "ssh-key-agent"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to allow Terraform to destroy the artifact bucket even if it contains objects."
  type        = bool
  default     = false
}
