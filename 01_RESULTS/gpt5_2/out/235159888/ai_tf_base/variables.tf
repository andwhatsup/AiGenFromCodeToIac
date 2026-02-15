variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "A short name used to namespace resources."
  type        = string
  default     = "cool-sharedservices-freeipa"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to allow Terraform to destroy the artifact bucket even if it contains objects."
  type        = bool
  default     = false
}
