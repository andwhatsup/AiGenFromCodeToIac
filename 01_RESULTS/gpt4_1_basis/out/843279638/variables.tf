variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "counter-app"
}

variable "container_port" {
  description = "Port the application container listens on."
  type        = number
  default     = 3000
}
