variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "py-calc-app"
}

variable "container_image" {
  description = "Container image to run (from Docker Hub or ECR). Repo includes a Kubernetes manifest referencing yash5090/py-calc-app:latest."
  type        = string
  default     = "yash5090/py-calc-app:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 5000
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 2
}
