variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "loan-calc"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 5000
}
