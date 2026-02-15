variable "app_name" {
  description = "A short name used to prefix/tag resources."
  type        = string
  default     = "iac-starter-kit"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}
