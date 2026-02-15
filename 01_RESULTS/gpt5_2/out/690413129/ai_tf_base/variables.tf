variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "mlflow"
}

variable "mlflow_port" {
  description = "Container port exposed by the MLflow service"
  type        = number
  default     = 5000
}

variable "mlflow_image" {
  description = "Container image for MLflow (public image by default)."
  type        = string
  default     = "ghcr.io/mlflow/mlflow:v2.5.0"
}

variable "mlflow_tracking_username" {
  description = "Basic auth username(s) for MLflow. Comma-delimited supported by the app."
  type        = string
  default     = "mlflow"
}

variable "mlflow_tracking_password" {
  description = "Basic auth password(s) for MLflow. Comma-delimited supported by the app."
  type        = string
  sensitive   = true
  default     = "mlflow"
}
