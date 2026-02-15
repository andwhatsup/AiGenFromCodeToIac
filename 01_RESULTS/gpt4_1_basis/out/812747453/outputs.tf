output "service_url" {
  description = "URL of the ECS service"
  value       = aws_lb.lb.dns_name
}
