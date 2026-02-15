output "ecs_cluster_name" {
  value = aws_ecs_cluster.minecraft.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.minecraft.repository_url
}

output "public_ip" {
  value = aws_ecs_service.minecraft_service.network_configuration[0].assign_public_ip
}
