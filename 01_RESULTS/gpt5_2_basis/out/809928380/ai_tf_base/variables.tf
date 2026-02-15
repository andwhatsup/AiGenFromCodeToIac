variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = "Application name used for resource naming and tagging."
  type        = string
  default     = "reminder-bot"
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
  default     = "reminder-bot-lambda"
}

variable "lambda_handler" {
  description = "Java handler (package.Class::method)."
  type        = string
  default     = "handler.Handler::handleRequest"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "java21"
}

variable "lambda_memory_size" {
  description = "Lambda memory size (MB)."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout (seconds)."
  type        = number
  default     = 30
}

variable "bot_token" {
  description = "Telegram bot token."
  type        = string
  sensitive   = true
}

variable "chat_id" {
  description = "Telegram chat id."
  type        = string
  sensitive   = true
}

variable "half_month_message" {
  description = "Message to send on day 15."
  type        = string
  sensitive   = true
}

variable "end_month_message" {
  description = "Message to send on other days (typically end of month)."
  type        = string
  sensitive   = true
}

variable "lambda_jar_path" {
  description = "Path to the built shaded JAR to deploy. Build with: mvn package (produces ./target/reminder-bot.jar)."
  type        = string
  default     = "../target/reminder-bot.jar"
}
