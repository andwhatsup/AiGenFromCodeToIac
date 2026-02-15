variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "mongodb-aws-ecs"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "MONGODB_URI" {
  description = "MongoDB Atlas connection URI"
  type        = string
}
