variable "app_name" {
  description = "Name for the application and resources."
  type        = string
  default     = "hello-world"
}

variable "image_name" {
  description = "Docker image to deploy (ECR or public)."
  type        = string
  default     = "robbiearms/hello-world:latest"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
