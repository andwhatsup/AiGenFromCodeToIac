provider "aws" {
  region = var.aws_region
}

# This module is intended to be used by Nebari inside an existing Kubernetes cluster.
# The Helm provider needs a Kubernetes config to talk to that cluster.
# We configure it to use the local kubeconfig by default.
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
