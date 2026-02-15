variable "image_name" {
  description = "The name of the Docker image"
  default     = "hendawyy/node-img:v1"
}

variable "internal_port" {
  description = "The internal port on which the application inside the container is listening"
  default     = 3000
}

variable "external_port" {
  description = "The external port on which you want to expose the container"
  default     = 8081
}
