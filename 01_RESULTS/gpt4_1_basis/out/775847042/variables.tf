variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "py-calc-app"
}

variable "container_port" {
  description = "Port the Flask app listens on."
  type        = number
  default     = 5000
}
