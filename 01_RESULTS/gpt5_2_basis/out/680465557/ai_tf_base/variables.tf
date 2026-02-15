variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "aws-iam-gitops"
}

variable "ecr_repo_name" {
  description = "ECR repository name to store the Lambda container image."
  type        = string
  default     = "aws-iam-gitops"
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
  default     = "aws-iam-gitops"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 120
}

variable "github_username" {
  description = "GitHub username that owns the repo to push IAM exports into."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name to push IAM exports into."
  type        = string
}

variable "github_token" {
  description = "GitHub token with write access to the repository."
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "ECR image tag for the Lambda container image."
  type        = string
  default     = "latest"
}

variable "eventbridge_schedule_expression" {
  description = "EventBridge schedule expression to trigger the Lambda."
  type        = string
  default     = "rate(1 day)"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs. Must be globally unique."
  type        = string
  default     = null
}

variable "cloudtrail_name" {
  description = "CloudTrail name."
  type        = string
  default     = "aws-iam-gitops"
}
