output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "endpoint" {
  description = "HTTP endpoint for the hello-world service."
  value       = "http://${aws_lb.this.dns_name}/"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
