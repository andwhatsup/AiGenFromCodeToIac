variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "strapi-app"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 1337
}

variable "image" {
  description = "Docker image for the application"
  type        = string
  default     = "camillehe1992/strapi:latest"
}
