variable "app_name" {
  description = "Application name prefix for resources."
  type        = string
  default     = "cann"
}

variable "schedule_expression" {
  description = "CloudWatch Event schedule expression."
  type        = string
  default     = "cron(*/1 6-20 ? * 2-6 *)"
}

variable "telegram_auth_token" {
  description = "Telegram bot auth token (stored in SSM Parameter Store)"
  type        = string
}
