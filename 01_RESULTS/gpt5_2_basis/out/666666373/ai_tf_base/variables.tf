variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "mvn-hello-world"
}

variable "container_image" {
  description = "Container image to run (from Docker Hub or ECR). Repo contains a Dockerfile that builds a Tomcat WAR image."
  type        = string
  default     = "balcha/banking_domin:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}
