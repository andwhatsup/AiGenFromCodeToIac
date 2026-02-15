variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "trigger-mwaa-dag"
}

variable "lambda_log_level" {
  description = "Log level for the Lambda function"
  type        = string
  default     = "INFO"
}
