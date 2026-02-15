variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "devops-interview-ac"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifact bucket (useful for dev/test)"
  type        = bool
  default     = true
}
