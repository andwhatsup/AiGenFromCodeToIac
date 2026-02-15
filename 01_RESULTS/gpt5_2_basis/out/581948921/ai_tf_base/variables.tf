variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application/site name used for resource naming."
  type        = string
  default     = "mkdocs-demo"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "force_destroy" {
  description = "Whether to allow Terraform to destroy the S3 bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default = {
    Project = "mkdocs-demo"
    Managed = "terraform"
  }
}
