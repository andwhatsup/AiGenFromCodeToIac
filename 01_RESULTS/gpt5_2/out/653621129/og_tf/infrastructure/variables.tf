variable "name" {
  type        = string
  description = "Name to apply to resources"
  default     = "franklin"
}

variable "tags" {
  type        = map(any)
  description = "Any additional tags to apply to created resources."
  default     = {}
}

variable "image_name" {
  type        = string
  description = "Docker respository + tag used as task"
  default     = "robbiearms/hello-world:latest"
}