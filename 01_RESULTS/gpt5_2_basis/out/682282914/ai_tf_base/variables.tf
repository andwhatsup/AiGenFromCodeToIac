variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "example-s3-localstack"
}

variable "bucket_name" {
  description = "S3 bucket name to create. Must be globally unique in real AWS."
  type        = string
  default     = "versionedexample"
}
