output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app_service.name
}
