output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "app_task_role_arn" {
  description = "ARN of the ECS Task Role"
  value       = aws_iam_role.app_task_role.arn
}
