variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "lambda-api"
}

variable "bucket_name" {
  description = "S3 bucket name for the app"
  type        = string
  default     = "lambda-api-bucket"
}
