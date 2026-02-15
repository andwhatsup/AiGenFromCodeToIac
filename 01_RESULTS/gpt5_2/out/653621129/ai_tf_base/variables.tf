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

variable "image_name" {
  description = "Container image to run (e.g., robbiearms/hello-world:latest)."
  type        = string
  default     = "robbiearms/hello-world:latest"
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Desired number of tasks."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
