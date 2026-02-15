variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "rocket-api"
}

variable "db_name" {
  description = "Name of the MySQL database."
  type        = string
  default     = "rocketseat-db"
}

variable "db_user" {
  description = "MySQL database user."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "MySQL database password."
  type        = string
  default     = "root"
  sensitive   = true
}
