variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "prefect-agent-ecs"
}

variable "prefect_api_url" {
  description = "Prefect API URL (e.g., https://api.prefect.cloud/api/accounts/<account_id>/workspaces/<workspace_id>)."
  type        = string
  default     = ""
}

variable "prefect_api_key" {
  description = "Prefect API key for the agent."
  type        = string
  default     = ""
  sensitive   = true
}

variable "prefect_work_queue" {
  description = "Prefect work queue name the agent should poll."
  type        = string
  default     = "test-queue"
}

variable "create_ecr_repository" {
  description = "Whether to create an ECR repository for a custom agent image."
  type        = bool
  default     = true
}
