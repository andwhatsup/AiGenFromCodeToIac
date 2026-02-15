variable "aws_region" {
  description = "AWS region (used for any AWS data sources/resources; kept for compatibility with Nebari stages)."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources created by this Terraform configuration."
  type        = string
  default     = "nebari-metrics-server"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig used by the Helm provider."
  type        = string
  default     = "~/.kube/config"
}

variable "name" {
  description = "Helm release name for metrics-server."
  type        = string
  default     = "metrics-server"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy metrics-server into."
  type        = string
  default     = "kube-system"
}

variable "affinity" {
  description = "Affinity configuration passed into the chart values."
  type = object({
    enabled  = optional(bool, true)
    selector = any
  })
  default = {
    enabled  = true
    selector = "general"
  }
}

variable "overrides" {
  description = "Arbitrary Helm values overrides (merged on top of defaults)."
  type        = any
  default     = {}
}
