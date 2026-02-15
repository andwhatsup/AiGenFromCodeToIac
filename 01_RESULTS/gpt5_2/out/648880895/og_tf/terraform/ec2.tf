#Create a new EC2 launch configuration
###########################
resource "aws_instance" "ec2_public" {
  ami                         = "ami-04a0ae173da5807d3"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  security_groups             = ["${aws_security_group.ssh-security-group.id}"]
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  depends_on                  = [local_file.ssh_key]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  user_data = file("userdata.tpl")

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name"        = "EC2-Public-Workshop"
    "Environment" = "production"
  }
}
