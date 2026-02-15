variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming and tagging."
  type        = string
  default     = "aws-comprehend-pipeline"
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name. If null, a unique name will be generated."
  type        = string
  default     = null
}

variable "text_prefix" {
  description = "S3 prefix for input text files."
  type        = string
  default     = "text/"
}

variable "comprehend_prefix" {
  description = "S3 prefix for comprehend output files."
  type        = string
  default     = "comprehend/"
}

variable "datalake_prefix" {
  description = "S3 prefix for datalake output files."
  type        = string
  default     = "datalake/"
}
