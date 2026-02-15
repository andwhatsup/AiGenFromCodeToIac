variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "ai-basis"
}

variable "container_port" {
  description = "Container port exposed by the application"
  type        = number
  default     = 80
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
  description = "Assign a public IP to the Fargate task (simplest for default VPC/public subnets)"
  type        = bool
  default     = true
}
