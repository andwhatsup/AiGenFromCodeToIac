variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "docker-node-hello"
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

variable "image" {
  description = "Container image to run. For a real deployment, push your built image to ECR and set this to the ECR image URI."
  type        = string
  default     = "public.ecr.aws/docker/library/node:18-alpine"
}
