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
  description = "How often to invoke the target lambda (seconds)."
  type        = number
  default     = 10
}

variable "duration_seconds" {
  description = "Total duration to run the loop (seconds). Must be a multiple of interval_seconds."
  type        = number
  default     = 60

  validation {
    condition     = var.duration_seconds > 0 && var.interval_seconds > 0 && var.duration_seconds % var.interval_seconds == 0
    error_message = "duration_seconds must be > 0 and a multiple of interval_seconds."
  }
}
