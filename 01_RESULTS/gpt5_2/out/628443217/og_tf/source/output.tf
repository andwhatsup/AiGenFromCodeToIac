# public ip
output "ec2_global_ips" {
  value = aws_instance.my_net_ec2.*.public_ip
}

# public dns name
output "ec2_public_dns_name" {
  value = aws_instance.my_net_ec2.*.public_dns
}

# ami_id
output "ami_id" {
  value = data.aws_ami.amazon-linux-image.id
}