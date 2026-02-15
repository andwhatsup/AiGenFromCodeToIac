variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "strapi"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "container_image" {
  description = "Container image URI (e.g., ECR image or Docker Hub image)"
  type        = string
  default     = "camillehe1992/strapi:latest"
}

variable "container_port" {
  description = "Container port exposed by the app"
  type        = number
  default     = 1337
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
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
  description = "Assign a public IP to the Fargate task ENI"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "ALB target group health check path"
  type        = string
  default     = "/"
}

variable "app_env" {
  description = "Environment variables passed to the container"
  type        = map(string)
  default = {
    HOST = "0.0.0.0"
    PORT = "1337"

    # Strapi secrets should be overridden in real deployments.
    APP_KEYS            = "toBeModified1,toBeModified2"
    API_TOKEN_SALT      = "tobemodified"
    ADMIN_JWT_SECRET    = "tobemodified"
    TRANSFER_TOKEN_SALT = "tobemodified"
    JWT_SECRET          = "tobemodified"

    # Default to sqlite for minimal infra; override to mysql/postgres as needed.
    DATABASE_CLIENT = "sqlite"
  }
}
