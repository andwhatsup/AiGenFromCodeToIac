variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "venmo-action-automation"
}

variable "venmo_auth_token" {
  description = "Venmo API access token used by the Lambda function"
  type        = string
  sensitive   = true
}

variable "alarm_email" {
  description = "Email address to subscribe to SNS topic for Lambda failure alarms"
  type        = string
  default     = ""
}

variable "venmo_schedules" {
  description = "List of EventBridge schedules to trigger the Lambda with a JSON payload"
  type = list(object({
    name            = string
    description     = optional(string, "")
    cron_expression = string
    payload         = string
  }))
  default = []
}
