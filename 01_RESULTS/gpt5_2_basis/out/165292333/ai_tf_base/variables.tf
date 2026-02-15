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
  description = "DynamoDB table name used by the Lambda function. Must match application code expectations."
  type        = string
  default     = "URLDB"
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
  default     = "url-shortener"
}

variable "api_name" {
  description = "API Gateway REST API name."
  type        = string
  default     = "url-shortener-api"
}
