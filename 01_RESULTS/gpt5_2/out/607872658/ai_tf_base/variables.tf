variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application / project name used for naming"
  type        = string
  default     = "ssm-parameter-backup"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "backup_schedule_expression" {
  description = "EventBridge schedule expression for running the backup"
  type        = string
  default     = "rate(1 day)"
}

variable "s3_force_destroy" {
  description = "Whether to allow Terraform to destroy the backup bucket even if it contains objects"
  type        = bool
  default     = false
}
