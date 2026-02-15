variable "lambda_function_name" {
  description = "Name for the Lambda function."
  type        = string
  default     = "delta-optimize-lambda"
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table used for locking."
  type        = string
  default     = "delta-optimize-lock"
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB for the Lambda function."
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout in seconds for the Lambda function."
  type        = number
  default     = 60
}
