output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.app.dns_name
}
