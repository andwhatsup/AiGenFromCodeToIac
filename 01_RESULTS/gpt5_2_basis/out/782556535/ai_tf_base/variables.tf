variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "terratest-localstack"
}

variable "aws_region" {
  description = "AWS region. For LocalStack, any region works."
  type        = string
  default     = "us-east-1"
}

variable "aws_endpoint_url" {
  description = "Base endpoint URL for LocalStack (e.g., http://localhost:4566). Leave empty to use real AWS endpoints."
  type        = string
  default     = "http://localhost:4566"
}

variable "aws_access_key" {
  description = "AWS access key (LocalStack default is 'test')."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key (LocalStack default is 'test')."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "aws_skip_credentials_validation" {
  description = "Skip AWS credentials validation (recommended for LocalStack)."
  type        = bool
  default     = true
}

variable "aws_skip_metadata_api_check" {
  description = "Skip metadata API check (recommended for LocalStack)."
  type        = bool
  default     = true
}

variable "aws_skip_requesting_account_id" {
  description = "Skip requesting account ID (recommended for LocalStack)."
  type        = bool
  default     = true
}

variable "aws_s3_use_path_style" {
  description = "Use path-style S3 URLs (recommended for LocalStack)."
  type        = bool
  default     = true
}
