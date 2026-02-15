variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "prefect_api_key" {
  description = "Prefect API key."
  type        = string
  sensitive   = true
}

variable "prefect_account_id" {
  description = "Prefect account ID."
  type        = string
}

variable "prefect_workspace_id" {
  description = "Prefect workspace ID."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS Fargate."
  type        = string
}

variable "agent_subnets" {
  description = "List of subnet IDs for ECS Fargate."
  type        = list(string)
}

variable "ecs_agent_name" {
  description = "Name for the ECS agent."
  type        = string
  default     = "prefect-ecs-agent"
}
