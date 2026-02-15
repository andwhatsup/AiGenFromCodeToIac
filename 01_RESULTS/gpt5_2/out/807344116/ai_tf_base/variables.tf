variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for created resources"
  type        = string
  default     = "epicac"
}

variable "ecr_repository_name" {
  description = "ECR repository name to push the application image to"
  type        = string
  default     = "epicac"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
