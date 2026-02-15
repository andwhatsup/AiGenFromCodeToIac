output "ec2_instance_id" {
  description = "ID of the EC2 instance running the portfolio website."
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.app_server.public_ip
}
