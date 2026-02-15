variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "trigger-mwaa-dag"
}

variable "log_level" {
  description = "Lambda log level"
  type        = string
  default     = "INFO"
}
