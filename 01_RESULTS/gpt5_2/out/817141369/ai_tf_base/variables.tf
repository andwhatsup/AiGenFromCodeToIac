variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "dinosaur-game"
}

variable "index_document" {
  description = "S3 website index document."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "S3 website error document."
  type        = string
  default     = "index.html"
}
