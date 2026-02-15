variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "ai-basis-app"
}
