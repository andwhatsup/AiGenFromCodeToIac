variable "lambda_name" {
  description = "Name for the iterator Lambda function"
  type        = string
  default     = "iterator-lambda"
}

variable "lambda_role_name" {
  description = "Name for the Lambda execution role"
  type        = string
  default     = "iterator-lambda-role"
}

variable "target_lambda_arn" {
  description = "ARN of the Lambda function to invoke repeatedly"
  type        = string
}
