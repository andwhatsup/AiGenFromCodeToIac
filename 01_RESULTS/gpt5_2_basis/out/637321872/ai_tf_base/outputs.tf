output "ami_id" {
  description = "AMI used for the Squid instance."
  value       = aws_instance.squid.ami
}

output "instance_id" {
  description = "EC2 instance id."
  value       = aws_instance.squid.id
}

output "public_ip" {
  description = "Public IP of the Squid instance."
  value       = aws_instance.squid.public_ip
}

output "public_dns" {
  description = "Public DNS name of the Squid instance."
  value       = aws_instance.squid.public_dns
}

output "proxy_endpoint" {
  description = "Convenience endpoint for configuring clients."
  value       = "${aws_instance.squid.public_ip}:${var.squid_port}"
}
