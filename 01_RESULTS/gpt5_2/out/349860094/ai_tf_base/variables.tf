variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Application name/prefix used for resource naming"
  type        = string
  default     = "cann"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression to trigger the check_announcement lambda (e.g. rate(15 minutes) or cron(...))"
  type        = string
}

variable "base_url" {
  description = "Base URL where announcements are published"
  type        = string
  default     = "http://www.gobcan.es/educacion/Nombramientos/Documentos"
}

variable "date_format" {
  description = "Date format used in announcements filenames"
  type        = string
  default     = "02-01-06"
}

variable "telegram_auth_token" {
  description = "Telegram bot auth token"
  type        = string
  sensitive   = true
}

variable "announcements" {
  description = "Map of announcement IDs to Telegram destination configuration"
  type = map(object({
    telegram_chat_id      = string
    telegram_channel_name = string
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    App         = "cann"
    CreatedBy   = "terraform"
    Environment = "production"
  }
}
