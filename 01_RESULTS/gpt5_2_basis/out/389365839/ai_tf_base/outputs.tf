output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the application image to"
  value       = aws_ecr_repository.app.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.postgres.address
}
