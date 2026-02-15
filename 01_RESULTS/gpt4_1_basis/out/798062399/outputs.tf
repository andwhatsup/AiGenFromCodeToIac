output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.notes_alb.dns_name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.notes_service.name
}
