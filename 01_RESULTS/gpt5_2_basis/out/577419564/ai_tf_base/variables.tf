variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "hello-war"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate task ENI (requires public subnets)"
  type        = bool
  default     = true
}

variable "image" {
  description = "Container image URI (e.g., ECR repo URL with tag)."
  type        = string
  default     = "tomcat:9.0.0.M10-jre8-alpine"
}
