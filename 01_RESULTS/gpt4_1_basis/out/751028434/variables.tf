variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "kubernetes_host" {
  description = "Kubernetes API server host."
  type        = string
}

variable "kubernetes_ca_certificate" {
  description = "Kubernetes cluster CA certificate (base64 encoded)."
  type        = string
}

variable "kubernetes_token" {
  description = "Kubernetes API token."
  type        = string
}

variable "metrics_server_name" {
  description = "Helm release name for metrics server."
  type        = string
  default     = "metrics-server"
}

variable "metrics_server_namespace" {
  description = "Namespace for metrics server."
  type        = string
  default     = "kube-system"
}

variable "metrics_server_affinity_enabled" {
  description = "Enable affinity for metrics server."
  type        = bool
  default     = true
}

variable "metrics_server_affinity_selector" {
  description = "Affinity selector for metrics server."
  type        = string
  default     = "general"
}

variable "metrics_server_overrides" {
  description = "Helm values overrides for metrics server."
  type        = map(any)
  default     = {}
}
