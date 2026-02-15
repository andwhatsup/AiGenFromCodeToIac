output "aws_region" {
  value       = var.aws_region
  description = "AWS region"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "ECR repository URL (push your built image here if you extend the pipeline)"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Public URL for the application"
}
