output "ecr_repository_url" {
  description = "ECR repository URL to push the image to"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL for the service"
  value       = aws_lb.this.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
