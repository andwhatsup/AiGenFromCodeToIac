output "instance_id" {
  description = "ID of the EC2 instance running the app."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP address of the app EC2 instance."
  value       = aws_instance.app.public_ip
}
