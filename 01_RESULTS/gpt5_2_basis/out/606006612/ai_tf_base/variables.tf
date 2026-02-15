variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "mongodb-aws-ecs"
}

variable "container_image" {
  description = "Container image URI (e.g., ECR image)"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB connection string (e.g., MongoDB Atlas URI)"
  type        = string
  sensitive   = true
}

variable "subnets" {
  description = "Subnet IDs for the ECS service (typically public subnets if assign_public_ip=true)"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs to attach to the ECS tasks"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "Existing ECS task execution role ARN (must allow pulling image + writing logs)"
  type        = string
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
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Assign a public IP to the task ENI (useful when running in public subnets without NAT)"
  type        = bool
  default     = true
}
