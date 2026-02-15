variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "go-server-template"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifacts bucket (useful for dev/test)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "go-server-template"
  }
}
