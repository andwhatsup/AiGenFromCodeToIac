variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "terratest-localstack"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

# LocalStack-friendly provider settings
variable "aws_endpoint_url" {
  description = "Base endpoint URL for LocalStack (e.g., http://localhost:4566). Leave empty to use real AWS endpoints."
  type        = string
  default     = "http://localhost:4566"
}

variable "aws_access_key_id" {
  description = "AWS access key (LocalStack default is 'test')."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret key (LocalStack default is 'test')."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "skip_credentials_validation" {
  description = "Skip AWS credentials validation (useful for LocalStack)."
  type        = bool
  default     = true
}

variable "skip_metadata_api_check" {
  description = "Skip metadata API check (useful for LocalStack)."
  type        = bool
  default     = true
}

variable "skip_requesting_account_id" {
  description = "Skip requesting account ID (useful for LocalStack)."
  type        = bool
  default     = true
}

variable "s3_use_path_style" {
  description = "Use path-style S3 URLs (often required for LocalStack when using localhost endpoint)."
  type        = bool
  default     = true
}

# Module variables used by the terratest in infra_tests
variable "tag_bucket_name" {
  description = "Value for the Name tag on the main bucket."
  type        = string
}

variable "tag_bucket_environment" {
  description = "Value for the Environment tag on the main bucket."
  type        = string
}

variable "with_policy" {
  description = "Whether to attach a bucket policy to the main bucket."
  type        = bool
  default     = true
}
