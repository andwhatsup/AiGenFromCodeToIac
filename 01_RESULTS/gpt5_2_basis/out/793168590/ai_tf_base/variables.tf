variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "test-sagemaker-deploy"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function that invokes the SageMaker endpoint."
  type        = string
  default     = "sagemaker-invoker"
}

variable "sagemaker_endpoint_name" {
  description = "SageMaker endpoint name to invoke."
  type        = string
  default     = "hello-world-endpoint"
}

variable "lambda_source_dir" {
  description = "Path to the lambda source directory (relative to this Terraform module)."
  type        = string
  default     = "../lambda/src"
}
