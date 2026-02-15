output "aws_account_id" {
  description = "AWS account id (useful for debugging/verification)."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region in use."
  value       = data.aws_region.current.id
}

output "helm_release_name" {
  description = "Deployed Helm release name."
  value       = helm_release.metrics_server.name
}

output "helm_release_namespace" {
  description = "Namespace where metrics-server is deployed."
  value       = helm_release.metrics_server.namespace
}
