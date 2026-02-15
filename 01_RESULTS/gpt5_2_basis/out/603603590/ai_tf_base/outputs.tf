output "instance_id" {
  value       = aws_instance.kafka_host.id
  description = "EC2 instance id running docker-compose"
}

output "public_ip" {
  value       = aws_instance.kafka_host.public_ip
  description = "Public IP of the docker host"
}

output "kafka_ui_url" {
  value       = "http://${aws_instance.kafka_host.public_ip}:8080"
  description = "Kafka UI URL"
}

output "kafka_bootstrap" {
  value       = "${aws_instance.kafka_host.public_ip}:9093"
  description = "Kafka bootstrap server (host listener)"
}
