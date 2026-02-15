variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "dinosaur-game"
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name. If null, a unique name will be generated."
  type        = string
  default     = null
}
