output "ecr_repository_url" {
  description = "ECR repository URL to push the image to (tag :latest)"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL for the service"
  value       = aws_lb.this.dns_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
