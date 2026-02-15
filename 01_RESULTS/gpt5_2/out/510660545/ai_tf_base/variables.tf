variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "A short name used to namespace resources."
  type        = string
  default     = "iac-starter-kit"
}

variable "state_bucket_name" {
  description = "Optional explicit name for the S3 bucket used for Terraform remote state (if you choose to use it). Must be globally unique."
  type        = string
  default     = null
}

variable "create_state_bucket" {
  description = "Whether to create an S3 bucket suitable for Terraform remote state."
  type        = bool
  default     = true
}

variable "create_lock_table" {
  description = "Whether to create a DynamoDB table suitable for Terraform state locking."
  type        = bool
  default     = true
}
