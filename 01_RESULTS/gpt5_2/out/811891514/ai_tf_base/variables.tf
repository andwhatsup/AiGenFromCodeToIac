variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "hello-world-node"
}

variable "container_image" {
  description = "Container image URI (e.g., ECR image)."
  type        = string
  default     = "public.ecr.aws/docker/library/node:16-alpine"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of tasks to run."
  type        = number
  default     = 1
}
