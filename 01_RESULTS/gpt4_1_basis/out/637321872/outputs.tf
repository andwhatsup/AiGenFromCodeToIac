output "instance_id" {
  description = "The ID of the Squid proxy EC2 instance."
  value       = aws_instance.squid_proxy.id
}

output "public_ip" {
  description = "The public IP address of the Squid proxy EC2 instance."
  value       = aws_instance.squid_proxy.public_ip
}
