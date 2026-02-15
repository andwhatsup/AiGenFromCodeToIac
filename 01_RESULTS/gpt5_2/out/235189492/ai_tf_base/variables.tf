variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "high-frequency-lambda"
}

variable "target_lambda_arn" {
  description = "ARN of the Lambda function to invoke at high frequency."
  type        = string
}

variable "interval_seconds" {
  description = "Wait time between invocations."
  type        = number
  default     = 10
}

variable "invocations_per_execution" {
  description = "How many times to invoke the target lambda per Step Functions execution."
  type        = number
  default     = 6
}
