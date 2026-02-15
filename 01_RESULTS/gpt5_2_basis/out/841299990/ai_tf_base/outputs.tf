output "ecr_repository_url" {
  description = "ECR repository URL. Push your image as :latest (or update task definition)."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL for the application (HTTP)."
  value       = aws_lb.app.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
