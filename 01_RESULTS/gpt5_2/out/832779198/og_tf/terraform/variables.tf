variable "aws_region" {
  description = "The AWS region"
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "The project credentials profile"
  default     = "enchant3dmango"
}

variable "s3_bucket_name" {
  description = "The S3 bucket name"
  default     = "emmer"
}

variable "lambda_function_name" {
  description = "The function name of Lambda"
  default     = "lambda-handler"
}

variable "lambda_role_name" {
  description = "The name of IAM Role of Lambda"
  default     = "lambda-role"
}

variable "prefix_ob" {
  description = "Prefix to apply to resource names"
  type        = string
  default     = "ob"
}

variable "suffix_dev" {
  description = "Suffix to apply to resource names"
  type        = string
  default     = "dev"
}
