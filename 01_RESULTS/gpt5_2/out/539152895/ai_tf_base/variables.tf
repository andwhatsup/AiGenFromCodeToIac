variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "learn-hcp-runners"
}

variable "container_port" {
  description = "Container port exposed by the application"
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

variable "image" {
  description = "Container image URI (e.g., public ECR, Docker Hub). Waypoint builds/pushes an image; provide it here."
  type        = string
}

variable "platform_env" {
  description = "Value for PLATFORM environment variable used by the Flask app"
  type        = string
  default     = "aws-ecs"
}
