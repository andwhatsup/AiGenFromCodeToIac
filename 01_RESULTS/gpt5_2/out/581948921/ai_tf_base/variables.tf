variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application/project name used for tagging and naming."
  type        = string
  default     = "mkdocs-demo"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "enable_public_website" {
  description = "Whether to enable S3 static website hosting and public read access."
  type        = bool
  default     = true
}

variable "index_document" {
  description = "Index document for S3 static website hosting."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for S3 static website hosting."
  type        = string
  default     = "404.html"
}
