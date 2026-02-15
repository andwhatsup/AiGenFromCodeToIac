variable "aws_region" {
  description = "AWS region to target. For LocalStack, this is typically any valid region (e.g., eu-central-1)."
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "localstack-demo"
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket (useful as a simple artifact bucket in LocalStack)."
  type        = bool
  default     = true
}

variable "create_dynamodb_table" {
  description = "Whether to create a DynamoDB table (useful for testing LocalStack DynamoDB + dynamodb-admin)."
  type        = bool
  default     = true
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name."
  type        = string
  default     = "example-table"
}
