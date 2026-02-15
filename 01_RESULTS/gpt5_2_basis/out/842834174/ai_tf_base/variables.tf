variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "range-slider"
}

variable "container_image" {
  description = "Container image to run (defaults to the image referenced by the repo's Kubernetes manifests)."
  type        = string
  default     = "yash5090/range-slider:latest"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of tasks to run."
  type        = number
  default     = 2
}
