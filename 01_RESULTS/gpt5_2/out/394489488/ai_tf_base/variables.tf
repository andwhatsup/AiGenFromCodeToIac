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
  description = "Comma-delimited list of MLflow basic-auth usernames."
  type        = string
  default     = "mlflow"
}

variable "mlflow_password" {
  description = "Comma-delimited list of MLflow basic-auth passwords (same count/order as usernames)."
  type        = string
  sensitive   = true
  default     = "mlflow"
}

variable "container_image" {
  description = "Container image to run in App Runner (e.g., ghcr.io/mlflow/mlflow:v2.5.0)."
  type        = string
  default     = "ghcr.io/mlflow/mlflow:v2.5.0"
}

variable "container_port" {
  description = "Port exposed by the container / App Runner service."
  type        = number
  default     = 5000
}

variable "create_backend_store" {
  description = "If true, create an RDS PostgreSQL instance for MLflow backend store. If false, MLflow uses local file store (not durable)."
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database username (only used when create_backend_store=true)."
  type        = string
  default     = "mlflow"
}

variable "db_password" {
  description = "Database password (only used when create_backend_store=true)."
  type        = string
  sensitive   = true
  default     = "mlflowmlflow"
}

variable "db_name" {
  description = "Database name (only used when create_backend_store=true)."
  type        = string
  default     = "mlflow"
}
