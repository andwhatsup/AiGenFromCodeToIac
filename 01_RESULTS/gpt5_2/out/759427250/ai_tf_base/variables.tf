variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "localstack-demo"
}

variable "aws_region" {
  description = "AWS region (or LocalStack default region)."
  type        = string
  default     = "eu-central-1"
}

# LocalStack-friendly defaults. For real AWS, override these.
variable "aws_endpoint" {
  description = "LocalStack edge endpoint (e.g., http://localhost:4566). Set to null to use real AWS endpoints."
  type        = string
  default     = "http://localhost:4566"
}

variable "aws_access_key_id" {
  description = "AWS access key id (LocalStack can use any value)."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key (LocalStack can use any value)."
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
  description = "Skip requesting account id (useful for LocalStack)."
  type        = bool
  default     = true
}

variable "s3_use_path_style" {
  description = "Use path-style S3 URLs (required for many LocalStack setups)."
  type        = bool
  default     = true
}
