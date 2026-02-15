variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "echo-server"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}
