variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "chatapp"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 12345
}
