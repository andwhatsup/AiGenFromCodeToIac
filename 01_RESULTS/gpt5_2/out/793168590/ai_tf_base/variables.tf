variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "test-sagemaker-deploy"
}

variable "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint to invoke"
  type        = string
  default     = "hello-world-endpoint"
}

variable "lambda_schedule_expression" {
  description = "EventBridge schedule expression (rate() or cron())"
  type        = string
  default     = "rate(1 hour)"
}
