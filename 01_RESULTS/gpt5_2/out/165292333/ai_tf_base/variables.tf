variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "url-shortener"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used by the Lambda function. Must match the hardcoded name in lambda.py unless you change the code."
  type        = string
  default     = "URLDB"
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
  default     = "url-shortener"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 256
}
