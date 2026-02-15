variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "kiwi"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  default     = "kiwi"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "infrafy"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "infrafy"
}
