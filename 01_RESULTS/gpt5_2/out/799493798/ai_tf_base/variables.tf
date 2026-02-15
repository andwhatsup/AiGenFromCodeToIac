variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "lambda-api"
}

variable "bucket_name" {
  description = "S3 bucket name used by the Lambda function"
  type        = string
  default     = null
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}
