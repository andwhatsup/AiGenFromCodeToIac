variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "mlflow-server"
}

variable "mlflow_username" {
  description = "Comma-delimited list of usernames for HTTP basic auth."
  type        = string
  default     = "mlflow"
}

variable "mlflow_password" {
  description = "Comma-delimited list of passwords for HTTP basic auth. Must align with mlflow_username order."
  type        = string
  sensitive   = true
  default     = "mlflow"
}

variable "container_port" {
  description = "Port exposed by the container / App Runner service."
  type        = number
  default     = 80
}
