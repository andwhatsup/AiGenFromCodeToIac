output "ecr_repository_url" {
  description = "ECR repository URL to push the application image to"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "service_name" {
  value = aws_ecs_service.app.name
}
