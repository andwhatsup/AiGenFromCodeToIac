output "host_ip" {
  value = aws_instance.example-instance.public_ip
}

output "host_name" {
  value = aws_instance.example-instance.public_dns
}

output "ssh_key" {
  value = aws_instance.example-instance.key_name
}