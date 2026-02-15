variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "react-joke-app"
}

variable "container_image" {
  description = "Container image to run (defaults to the image referenced by the repo's Kubernetes manifest)."
  type        = string
  default     = "yash5090/react-jg-app:latest"
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}
