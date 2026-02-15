variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "echo-server"
}

variable "container_port" {
  description = "Container port exposed by the application"
  type        = number
  default     = 8080
}

variable "environment" {
  description = "Value for ENVIRONMENT environment variable"
  type        = string
  default     = "prod"
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)"
  type        = number
  default     = 512
}

variable "image" {
  description = "Container image URI (e.g., ECR repo URL + tag). If empty, uses the created ECR repo with tag 'latest'."
  type        = string
  default     = ""
}
