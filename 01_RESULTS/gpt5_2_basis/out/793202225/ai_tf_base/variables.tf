variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "axum-app"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
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

variable "desired_count" {
  description = "Number of tasks"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate task (for default VPC public subnets)"
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image to run. Use a prebuilt image URI (e.g., from ECR)."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:latest"
}
