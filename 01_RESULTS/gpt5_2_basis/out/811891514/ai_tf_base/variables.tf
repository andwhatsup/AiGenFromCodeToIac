variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "hello-node"
}

variable "container_image" {
  description = "Container image URI to run in ECS (e.g., ECR image or public image)."
  type        = string
  default     = "public.ecr.aws/docker/library/node:16-alpine"
}

variable "container_port" {
  description = "Port the application listens on inside the container."
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks to run."
  type        = number
  default     = 1
}
