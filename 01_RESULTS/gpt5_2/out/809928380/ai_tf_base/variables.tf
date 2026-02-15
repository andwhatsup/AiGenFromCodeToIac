variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "reminder-bot"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "reminder-bot-lambda"
}

variable "lambda_handler" {
  description = "Java Lambda handler (package.Class::method)"
  type        = string
  default     = "handler.Handler::handleRequest"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "java21"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_jar_path" {
  description = "Path to the built shaded JAR to deploy (relative to this Terraform module directory)"
  type        = string
  default     = "../target/reminder-bot.jar"
}

variable "bot_token" {
  description = "Telegram bot token"
  type        = string
  sensitive   = true
}

variable "chat_id" {
  description = "Telegram chat id"
  type        = string
  sensitive   = true
}

variable "half_month_message" {
  description = "Message to send on day 15"
  type        = string
  sensitive   = true
}

variable "end_month_message" {
  description = "Message to send on other days (end of month reminder)"
  type        = string
  sensitive   = true
}

variable "schedule_expression" {
  description = "EventBridge schedule expression to trigger the Lambda"
  type        = string
  # Run daily at 09:00 UTC. The function itself decides which message to send.
  default = "cron(0 9 * * ? *)"
}
