variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "helloworld-app"
}

variable "artifact_bucket_name" {
  description = "Optional explicit S3 bucket name for artifacts. Leave null to let Terraform generate one."
  type        = string
  default     = null
}
