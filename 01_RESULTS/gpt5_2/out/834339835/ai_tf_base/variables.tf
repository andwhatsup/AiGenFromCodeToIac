variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "loan-calc"
}

variable "enable_static_site" {
  description = "If true, create an S3 static website bucket (public)."
  type        = bool
  default     = true
}
