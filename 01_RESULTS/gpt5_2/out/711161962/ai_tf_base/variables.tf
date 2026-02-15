variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-1"
}

variable "app_name" {
  description = "Application name used for resource naming/tagging."
  type        = string
  default     = "localstack-s3-sqs-lambda"
}

variable "bucket_name" {
  description = "Optional fixed S3 bucket name. Leave null to have Terraform generate a unique name."
  type        = string
  default     = null
}
