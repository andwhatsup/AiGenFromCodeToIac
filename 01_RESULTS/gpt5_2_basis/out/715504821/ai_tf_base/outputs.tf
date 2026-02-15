output "ecr_repository_url" {
  description = "ECR repository URL to push the application image to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "default_vpc_id" {
  value = data.aws_vpc.default.id
}
