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
  description = "Text returned by the http-echo service."
  type        = string
  default     = "hello world"
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 5678
}
