variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "aws-rekognition"
}

variable "artifact_bucket_name" {
  description = "Optional explicit S3 bucket name for artifacts/results. If null, a unique name is generated."
  type        = string
  default     = null
}
