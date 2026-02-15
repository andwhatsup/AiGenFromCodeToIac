variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "calculator-flask"
}

variable "container_image" {
  description = "Container image to run (repo includes a Dockerfile; default uses the image referenced by the Kubernetes manifest)"
  type        = string
  default     = "yash5090/calculator-flask:latest"
}

variable "container_port" {
  description = "Container port exposed by the Flask app"
  type        = number
  default     = 5000
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 2
}
