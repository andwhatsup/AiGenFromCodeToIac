variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "helloworld-app"
}

variable "kube_host" {
  description = "Kubernetes API server host."
  type        = string
}

variable "kube_token" {
  description = "Kubernetes API token."
  type        = string
  sensitive   = true
}

variable "kube_ca_cert" {
  description = "Kubernetes cluster CA certificate (base64 encoded)."
  type        = string
}
