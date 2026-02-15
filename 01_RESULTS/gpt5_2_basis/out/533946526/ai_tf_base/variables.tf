variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for created resources."
  type        = string
  default     = "rancher-cluster"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to allow Terraform to destroy the artifacts bucket even if it contains objects."
  type        = bool
  default     = false
}
