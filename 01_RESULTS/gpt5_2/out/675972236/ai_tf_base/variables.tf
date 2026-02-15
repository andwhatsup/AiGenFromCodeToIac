variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "rigitbot"
}

variable "lambda_architecture" {
  description = "Lambda architecture"
  type        = string
  default     = "arm64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.lambda_architecture)
    error_message = "lambda_architecture must be one of: arm64, x86_64"
  }
}

variable "lambda_runtime" {
  description = "Lambda runtime for the function"
  type        = string
  default     = "provided.al2023"
}

variable "lambda_handler" {
  description = "Lambda handler (for custom runtimes this is typically 'bootstrap')"
  type        = string
  default     = "bootstrap"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package zip (must exist before apply)."
  type        = string
  default     = "../build/rigitbot.zip"
}

variable "enable_function_url" {
  description = "Whether to create a Lambda Function URL (public)"
  type        = bool
  default     = true
}
