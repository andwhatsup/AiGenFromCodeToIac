variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name for the Lambda function."
  type        = string
  default     = "reminder-bot"
}

variable "lambda_runtime" {
  description = "Lambda runtime environment."
  type        = string
  default     = "java21"
}
