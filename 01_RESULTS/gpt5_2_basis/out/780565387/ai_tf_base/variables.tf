variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "http-echo"
}

variable "echo_text" {
  description = "Text returned by the http-echo service. Must be non-empty."
  type        = string
  default     = "hello world"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 5678
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

variable "desired_count" {
  description = "Number of tasks to run."
  type        = number
  default     = 1
}
