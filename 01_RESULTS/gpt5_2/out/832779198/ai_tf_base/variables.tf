variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming and tagging."
  type        = string
  default     = "ontwikkelingsbedrywighede"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package zip file."
  type        = string
  default     = "../lambda.zip"
}

variable "source_prefix" {
  description = "S3 prefix that triggers the Lambda function."
  type        = string
  default     = "source/"
}

variable "destination_prefix" {
  description = "S3 prefix where objects are moved to by the Lambda function."
  type        = string
  default     = "destination/"
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
