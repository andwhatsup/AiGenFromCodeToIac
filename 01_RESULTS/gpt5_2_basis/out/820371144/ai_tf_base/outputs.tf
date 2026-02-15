output "ecr_repository_url" {
  description = "ECR repository URL to push the image to (tag :latest)."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL of the application load balancer."
  value       = aws_lb.this.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}
