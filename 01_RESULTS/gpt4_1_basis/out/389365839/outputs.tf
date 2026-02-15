output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.app.dns_name
}

output "db_instance_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.app.endpoint
}
