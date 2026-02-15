variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "artifact_bucket_name" {
  description = "Name for the S3 bucket to store artifacts"
  type        = string
  default     = null
}
