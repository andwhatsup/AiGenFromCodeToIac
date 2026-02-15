variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Application name used for resource naming/tagging."
  type        = string
  default     = "llm-documentation"
}
