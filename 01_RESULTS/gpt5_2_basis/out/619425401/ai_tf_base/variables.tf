variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "lambda-delta-optimize"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package zip (built by cargo lambda)."
  type        = string
  default     = "../target/lambda/lambda-delta-optimize/bootstrap.zip"
}

variable "datalake_location" {
  description = "s3:// URL of the Delta table to optimize"
  type        = string
}

variable "optimize_ds" {
  description = "Optional ds partition optimization selector. Use 'yesterday' to optimize yesterday's ds partition."
  type        = string
  default     = "yesterday"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression to trigger the Lambda"
  type        = string
  default     = "rate(1 day)"
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 900
}
