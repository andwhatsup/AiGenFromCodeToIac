output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image to."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "service_url" {
  description = "Convenience URL for the service."
  value       = "http://${aws_lb.this.dns_name}/"
}
