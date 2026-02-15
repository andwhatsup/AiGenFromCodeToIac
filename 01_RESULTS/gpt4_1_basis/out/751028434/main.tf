resource "helm_release" "metrics_server" {
  name       = var.metrics_server_name
  namespace  = var.metrics_server_namespace
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"

  set {
    name  = "affinity.enabled"
    value = tostring(var.metrics_server_affinity_enabled)
  }

  set {
    name  = "affinity.selector"
    value = var.metrics_server_affinity_selector
  }

  dynamic "set" {
    for_each = var.metrics_server_overrides
    content {
      name  = set.key
      value = set.value
    }
  }
}
