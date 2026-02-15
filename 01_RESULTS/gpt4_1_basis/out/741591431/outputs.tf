output "cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "service_load_balancer_hostname" {
  description = "Service Load Balancer Hostname"
  value       = aws_lb.app_lb.dns_name
}
