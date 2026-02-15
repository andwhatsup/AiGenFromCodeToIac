variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "dash-dashboard-demo"
}

variable "artifact_bucket_name" {
  description = "Optional pre-defined S3 bucket name for application artifacts. Leave null to auto-generate."
  type        = string
  default     = null
}
