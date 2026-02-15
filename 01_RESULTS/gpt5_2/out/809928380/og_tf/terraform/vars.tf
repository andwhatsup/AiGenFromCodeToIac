variable "bot_token" {
  description = "This is the telegram bot token"
  type        = string
  sensitive   = true
}

variable "chat_id" {
  description = "This is the telegram chat id"
  type        = string
  sensitive   = true
}

variable "half_month_message" {
  description = "Reminder message that the bot will send in the half of the month (15th)"
  type        = string
  sensitive   = true
}

variable "end_month_message" {
  description = "Reminder message that the bot will send in the final of the month (28th)"
  type        = string
  sensitive   = true
}