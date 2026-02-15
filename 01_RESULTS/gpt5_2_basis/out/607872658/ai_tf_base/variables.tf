variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application / project name used for naming."
  type        = string
  default     = "ssm-parameter-store-backup"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "backup_schedule_expression" {
  description = "EventBridge schedule expression for running the backup Lambda."
  type        = string
  default     = "rate(1 day)"
}

variable "s3_force_destroy" {
  description = "Whether to force destroy the backup bucket (dangerous in prod)."
  type        = bool
  default     = false
}
