variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ca-central-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "playwright-lambda"
}

variable "ecr_repository_name" {
  description = "ECR repository name for the Lambda container image"
  type        = string
  default     = "playwright-lambda"
}

variable "lambda_image_tag" {
  description = "Container image tag in ECR"
  type        = string
  default     = "latest"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 1024
}
