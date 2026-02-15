variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "product-api"
}

variable "stage_name" {
  description = "API Gateway stage name."
  type        = string
  default     = "dev"
}

variable "lambda_jar_path" {
  description = "Path to the Lambda JAR artifact (relative to this Terraform module)."
  type        = string
  default     = "../product-lambda.jar"
}
