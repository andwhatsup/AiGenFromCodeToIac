output "ecr_repository_url" {
  description = "URL of the ECR repository for the app image."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_service_name" {
  description = "ECS Service name."
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}
