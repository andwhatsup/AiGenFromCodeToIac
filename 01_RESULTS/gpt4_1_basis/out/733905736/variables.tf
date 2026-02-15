variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "sonarqube"
}
