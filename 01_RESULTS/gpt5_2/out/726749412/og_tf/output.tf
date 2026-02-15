output "subnet1_id" {
  value = aws_subnet.pub_one.id
}

output "subnet2_id" {
  value = aws_subnet.pub_two.id
}

output "subnet3_id" {
  value = aws_subnet.priv_one.id
}

output "subnet4_id" {
  value = aws_subnet.priv_two.id
}