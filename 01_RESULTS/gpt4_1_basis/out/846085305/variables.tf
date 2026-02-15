variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "home-automation"
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB for the Lambda function."
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout in seconds for the Lambda function."
  type        = number
  default     = 30
}
