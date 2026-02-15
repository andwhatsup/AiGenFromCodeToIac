variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "hello-world"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "hello-world-repo"
}

variable "container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 3000
}
