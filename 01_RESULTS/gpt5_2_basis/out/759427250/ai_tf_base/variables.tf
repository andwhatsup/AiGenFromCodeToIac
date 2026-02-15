variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "localstack-project"
}

variable "aws_region" {
  description = "AWS region (also used by LocalStack)."
  type        = string
  default     = "eu-central-1"
}

variable "aws_endpoint" {
  description = "LocalStack edge endpoint (e.g., http://localhost:4566). Set to null to use real AWS."
  type        = string
  default     = "http://localhost:4566"
}

variable "aws_access_key" {
  description = "Access key (LocalStack default can be any value)."
  type        = string
  default     = "test"
}

variable "aws_secret_key" {
  description = "Secret key (LocalStack default can be any value)."
  type        = string
  default     = "test"
}
