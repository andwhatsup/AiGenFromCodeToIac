variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "mlflow-server"
}

variable "mlflow_username" {
  description = "Comma-delimited list of usernames for HTTP basic auth"
  type        = string
  default     = "mlflow"
}

variable "mlflow_password" {
  description = "Comma-delimited list of passwords for HTTP basic auth (must align with usernames)"
  type        = string
  sensitive   = true
  default     = "mlflow"
}

variable "container_port" {
  description = "Port exposed by the container / App Runner service"
  type        = number
  default     = 80
}
