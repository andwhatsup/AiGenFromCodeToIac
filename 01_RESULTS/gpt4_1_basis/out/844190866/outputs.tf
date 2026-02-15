output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app_service.name
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_alb.dns_name
}
