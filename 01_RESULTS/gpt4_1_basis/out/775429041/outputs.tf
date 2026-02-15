output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.react_jg_app.name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.react_jg_app.dns_name
}
