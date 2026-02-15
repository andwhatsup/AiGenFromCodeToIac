variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "natanaelvich-api"
}

variable "ecr_repository_name" {
  description = "ECR repository name for the application image"
  type        = string
  default     = "natanaelvich-ci"
}

variable "image_tag" {
  description = "Container image tag to deploy (e.g., 'latest' or a git SHA)"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "App Runner CPU in vCPU units (allowed: 0.25, 0.5, 1, 2, 4)"
  type        = number
  default     = 1

  validation {
    condition     = contains([0.25, 0.5, 1, 2, 4], var.cpu)
    error_message = "cpu must be one of: 0.25, 0.5, 1, 2, 4 (vCPU)."
  }
}

variable "memory" {
  description = "App Runner memory in GB (allowed: 0.5, 1, 2, 3, 4, 6, 8, 10, 12)"
  type        = number
  default     = 2

  validation {
    condition     = contains([0.5, 1, 2, 3, 4, 6, 8, 10, 12], var.memory)
    error_message = "memory must be one of: 0.5, 1, 2, 3, 4, 6, 8, 10, 12 (GB)."
  }
}
