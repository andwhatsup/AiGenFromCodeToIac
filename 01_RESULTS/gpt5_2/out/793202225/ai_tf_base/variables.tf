variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "axum-app"
}

variable "container_image" {
  description = "Container image to run. For a real deployment, push your built image to ECR and set this to the ECR image URI."
  type        = string
  default     = "public.ecr.aws/docker/library/httpd:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}
