variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "strapi"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "container_image" {
  description = "Container image URI for the Strapi app (e.g., ECR or Docker Hub)."
  type        = string
  default     = "camillehe1992/strapi:latest"
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Container port exposed by Strapi."
  type        = number
  default     = 1337
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512
}

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate task ENI."
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/"
}

variable "strapi_environment" {
  description = "Environment variables passed to the Strapi container. Secrets should be injected via a secrets manager in real deployments."
  type        = map(string)
  default = {
    HOST = "0.0.0.0"
    PORT = "1337"
  }
}
