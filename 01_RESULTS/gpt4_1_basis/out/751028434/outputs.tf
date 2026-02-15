output "metrics_server_release_name" {
  description = "The Helm release name for the metrics server."
  value       = helm_release.metrics_server.name
}

output "metrics_server_namespace" {
  description = "The namespace where the metrics server is deployed."
  value       = helm_release.metrics_server.namespace
}
