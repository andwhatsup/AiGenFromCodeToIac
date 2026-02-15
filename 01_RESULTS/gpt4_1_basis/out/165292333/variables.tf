variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "url_shortener_lambda"
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table"
  type        = string
  default     = "URLDB"
}
