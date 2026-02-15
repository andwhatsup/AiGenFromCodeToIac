variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "rigitbot"
}

variable "lambda_architectures" {
  description = "Lambda instruction set architectures"
  type        = list(string)
  default     = ["x86_64"]
}

variable "lambda_runtime" {
  description = "Lambda runtime (for custom runtime use provided.al2)"
  type        = string
  default     = "provided.al2"
}

variable "lambda_handler" {
  description = "Lambda handler (ignored for custom runtime, but required by API)"
  type        = string
  default     = "bootstrap"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_package_path" {
  description = "Path to a pre-built Lambda deployment package (zip). Terraform will not build the Rust binary."
  type        = string
  default     = "./lambda.zip"
}
