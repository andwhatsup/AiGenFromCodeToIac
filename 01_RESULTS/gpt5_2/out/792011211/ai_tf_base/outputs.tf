output "aws_region" {
  value = var.aws_region
}

output "ecr_repository_url" {
  description = "Push your built Docker image to this repository URL (tag :latest)."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL for the application (HTTP)."
  value       = aws_lb.this.dns_name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN used for API_KEY injection."
  value       = aws_secretsmanager_secret.openweather.arn
}
