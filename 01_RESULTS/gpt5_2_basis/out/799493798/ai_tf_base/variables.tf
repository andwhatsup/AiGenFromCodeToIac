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

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "bucket_name" {
  description = "S3 bucket name used by the Lambda function"
  type        = string
  default     = null
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package (zip)"
  type        = string
  default     = "../lambda_function.zip"
}
