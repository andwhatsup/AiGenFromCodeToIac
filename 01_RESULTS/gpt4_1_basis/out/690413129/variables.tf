variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "mlflow-server"
}

variable "mlflow_artifact_bucket_name" {
  description = "S3 bucket name for MLflow artifacts."
  type        = string
  default     = ""
}
