variable "lambda_function_name" {
  description = "Name for the Lambda function."
  type        = string
  default     = "venmo-action-automation"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function."
  type        = string
  default     = "handler.handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function."
  type        = string
  default     = "python3.11"
}

variable "venmo_auth_token" {
  description = "Venmo API Auth Token."
  type        = string
  sensitive   = true
}
