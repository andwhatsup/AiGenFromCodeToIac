output "endpoint" {
  description = "The HTTP endpoint of the application."
  value       = aws_lb.app_lb.dns_name
}
