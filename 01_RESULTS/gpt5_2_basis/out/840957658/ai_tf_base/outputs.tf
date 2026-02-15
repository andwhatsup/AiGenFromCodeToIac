output "aws_region" {
  value = var.aws_region
}

output "ecr_repository_url" {
  description = "Push your built Docker image here (tag must match var.image_tag)."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL for the application."
  value       = aws_lb.this.dns_name
}
