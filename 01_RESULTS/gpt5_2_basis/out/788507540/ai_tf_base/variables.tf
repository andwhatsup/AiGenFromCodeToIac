variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "go-server-template"
}

variable "artifact_bucket_name" {
  description = "Optional explicit S3 bucket name for artifacts (leave null to auto-generate)"
  type        = string
  default     = null
}
