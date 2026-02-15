variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application/workshop name used for naming/tagging."
  type        = string
  default     = "aws-boto3-workshop"
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name. A random suffix will be appended to ensure global uniqueness."
  type        = string
  default     = "s3-bucket-workshop"
}
