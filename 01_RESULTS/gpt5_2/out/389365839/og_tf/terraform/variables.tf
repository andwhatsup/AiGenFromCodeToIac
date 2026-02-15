variable "pg_dsn" {
  description = "Connection string for Postgres RDS instance"
  type        = string
  sensitive   = true
  default     = "placeholder"
}

variable "image_tag" {
  description = "Container image tag, corresponds to commit SHA"
  type        = string
  default     = "placeholder"
}