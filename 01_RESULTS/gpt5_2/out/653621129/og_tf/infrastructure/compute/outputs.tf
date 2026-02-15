output "alb_dns" {
  value       = aws_lb.hello_alb.dns_name
  description = "DNS name for the ALB that will serve the hello world service externally"
}