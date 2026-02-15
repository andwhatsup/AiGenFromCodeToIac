variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "nodejs-docker-example"
}

variable "container_port" {
  description = "Port the container listens on. This repo is a test container; default to 3000 for a typical Node app."
  type        = number
  default     = 3000
}
