variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "tribute"
}

variable "container_image" {
  description = "Container image to run (repo uses a prebuilt public image in k8s manifests)"
  type        = string
  default     = "yash5090/tribute:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 2
}
