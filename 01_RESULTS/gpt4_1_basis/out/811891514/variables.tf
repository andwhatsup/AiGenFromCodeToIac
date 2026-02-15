variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "hello_world_app"
}

variable "container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 3000
}
