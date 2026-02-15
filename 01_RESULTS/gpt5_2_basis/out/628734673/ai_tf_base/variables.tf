variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "python-webapp"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
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

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate task (for default VPC public subnets)"
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image to run. Use an ECR image URI or any public image."
  type        = string
  default     = "xmaeltht/python-webapp:latest"
}
