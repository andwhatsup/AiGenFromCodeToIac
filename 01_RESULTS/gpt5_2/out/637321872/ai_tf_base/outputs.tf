output "ami_id" {
  description = "AMI used for the EC2 instance"
  value       = data.aws_ami.amazon_linux_2.id
}

output "instance_id" {
  value = aws_instance.squid.id
}

output "public_ip" {
  value = aws_instance.squid.public_ip
}

output "public_dns" {
  value = aws_instance.squid.public_dns
}

output "proxy_endpoint" {
  description = "Convenience endpoint for the Squid proxy"
  value       = "http://${aws_instance.squid.public_dns}:${var.squid_port}"
}
