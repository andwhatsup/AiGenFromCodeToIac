data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Minimal default values for the metrics-server chart.
  # Users can override anything via var.overrides.
  default_values = {
    affinity = var.affinity
  }

  merged_values = merge(local.default_values, try(var.overrides, {}))

  tags = {
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}

resource "helm_release" "metrics_server" {
  name      = var.name
  namespace = var.namespace

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  # Pin a stable chart version for deterministic plans.
  # (This can be overridden by editing this module if needed.)
  version = "3.12.1"

  create_namespace = true

  values = [yamlencode(local.merged_values)]
}
