variable "docker_image" {
  description = "The Docker image to deploy"
  type        = string
  default     = "xmaeltht/python-webapp"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "kubeconfig.yaml"
}
