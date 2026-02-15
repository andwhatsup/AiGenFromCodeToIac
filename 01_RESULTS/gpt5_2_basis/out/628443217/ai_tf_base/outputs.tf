output "ami_id" {
  description = "AMI used for the instance."
  value       = data.aws_ami.amazon_linux2.id
}

output "instance_id" {
  description = "EC2 instance id."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the instance."
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance."
  value       = aws_instance.web.public_dns
}
