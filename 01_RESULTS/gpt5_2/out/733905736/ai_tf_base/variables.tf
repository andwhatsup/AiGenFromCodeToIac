variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "sonarqube"
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to force-destroy the artifacts bucket (useful for dev/test)."
  type        = bool
  default     = true
}
