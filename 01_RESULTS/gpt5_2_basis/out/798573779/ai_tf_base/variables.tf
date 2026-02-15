variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "ai-basis"
}

variable "ecr_repository_name" {
  description = "ECR repository name for the container image."
  type        = string
  default     = "ai-basis-nginx"
}

variable "artifact_bucket_name" {
  description = "Optional fixed name for the artifacts bucket. Leave null to let Terraform generate a unique name."
  type        = string
  default     = null
}
