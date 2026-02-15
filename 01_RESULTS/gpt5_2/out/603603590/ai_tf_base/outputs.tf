output "instance_id" {
  value       = aws_instance.this.id
  description = "EC2 instance id"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP of the instance"
}

output "kafka_ui_url" {
  value       = "http://${aws_instance.this.public_ip}:8080"
  description = "Kafka UI URL"
}

output "nginx_proxy_manager_url" {
  value       = "http://${aws_instance.this.public_ip}:81"
  description = "Nginx Proxy Manager admin URL"
}
