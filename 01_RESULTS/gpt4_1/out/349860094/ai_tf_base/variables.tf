variable "app_name" {
  description = "Application name prefix for resources."
  type        = string
  default     = "cann"
}

variable "schedule_expression" {
  description = "CloudWatch cron schedule for Lambda trigger."
  type        = string
  default     = "cron(*/1 6-20 ? * 2-6 *)"
}

variable "base_url" {
  description = "Base URL for announcements."
  type        = string
  default     = "http://www.gobcan.es/educacion/Nombramientos/Documentos"
}

variable "date_format" {
  description = "Date format for announcements."
  type        = string
  default     = "02-01-06"
}

variable "telegram_auth_token_param" {
  description = "SSM Parameter name for Telegram auth token."
  type        = string
  default     = "/announcements/telegram/auth_token"
}
