variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "hello-world"
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "container_image" {
  description = "Container image to run (e.g., robbiearms/hello-world:latest)."
  type        = string
  default     = "robbiearms/hello-world:latest"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}
