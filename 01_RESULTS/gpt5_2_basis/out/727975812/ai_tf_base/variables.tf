variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "venmo-action-automation"
}

variable "venmo_auth_token" {
  description = "Venmo API access token used by the Lambda function"
  type        = string
  sensitive   = true
}

variable "alarm_email" {
  description = "Email address to subscribe to SNS alerts for Lambda failures"
  type        = string
  default     = null
}

variable "venmo_schedules" {
  description = <<EOT
List of schedules to create. Each schedule triggers the Lambda with the provided payload.

Example:
[
  {
    name            = "RentPayment"
    description     = "Monthly rent"
    cron_expression = "cron(0 9 1 * ? *)"
    payload         = jsonencode({ amount = 850, action = "payment", note = "Rent", recipient_user_name = "user" })
  }
]
EOT

  type = list(object({
    name            = string
    description     = optional(string)
    cron_expression = string
    payload         = string
  }))

  default = []
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
