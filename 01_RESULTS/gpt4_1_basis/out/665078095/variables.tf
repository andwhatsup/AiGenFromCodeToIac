variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "app"
}

variable "db_username" {
  description = "Username for the RDS instance."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS instance."
  type        = string
  sensitive   = true
}
