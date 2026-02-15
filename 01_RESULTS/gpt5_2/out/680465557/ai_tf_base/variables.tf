variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "aws-iam-gitops"
}

variable "github_username" {
  description = "GitHub username that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name to push IAM exports into"
  type        = string
}

variable "github_token" {
  description = "GitHub token with write access to the repo"
  type        = string
  sensitive   = true
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 120
}

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  type        = string
  default     = "rate(1 day)"
}
