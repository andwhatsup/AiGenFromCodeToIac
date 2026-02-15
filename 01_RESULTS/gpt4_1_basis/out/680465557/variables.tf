variable "github_username" {
  description = "GitHub username for repo access."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "github_token" {
  description = "GitHub token with write access."
  type        = string
  sensitive   = true
}

variable "random_suffix" {
  description = "Random suffix for resource names."
  type        = string
  default     = "31"
}

variable "random_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "aws-iam-gitops"
}

variable "ecr_repo_name" {
  description = "ECR repository name."
  type        = string
  default     = "aws-iam-gitops"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds."
  type        = number
  default     = 120
}
