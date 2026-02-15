variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "mlflow-server"
}

variable "mlflow_port" {
  description = "Port for the MLflow server"
  type        = number
  default     = 80
}

variable "mlflow_artifact_bucket" {
  description = "S3 bucket for MLflow artifacts"
  type        = string
  default     = ""
}
