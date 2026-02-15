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

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "aws_access_key_id" {
  description = "Access key for LocalStack (dummy is fine)."
  type        = string
  default     = "devopshobbies"
}

variable "aws_secret_access_key" {
  description = "Secret key for LocalStack (dummy is fine)."
  type        = string
  default     = "devopshobbies"
}
