variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "node-hello"
}

variable "container_port" {
  description = "Port the Node.js app listens on inside the container."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Container image to run. Use a public image (e.g., Docker Hub) to keep infra minimal."
  type        = string
  default     = "public.ecr.aws/docker/library/node:20-alpine"
}
