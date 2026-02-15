variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "mongodb-aws-ecs"
}

variable "container_image" {
  description = "Container image URI (e.g., ECR image)"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "Subnets for the ECS service (typically public subnets if assign_public_ip=true)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups to attach to the ECS tasks"
  type        = list(string)
  default     = []
}

variable "create_task_execution_role" {
  description = "Whether to create an ECS task execution role (set false to use an existing role ARN)"
  type        = bool
  default     = true
}

variable "execution_role_arn" {
  description = "Existing ECS task execution role ARN (used when create_task_execution_role=false)"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate task (useful for reaching MongoDB Atlas without NAT)"
  type        = bool
  default     = true
}
