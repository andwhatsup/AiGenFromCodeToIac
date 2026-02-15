# EC2 Key pair
variable "key_name" {
  default = "my-net-keypair"
}

# key algorithm
resource "tls_private_key" "my_net_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# generate key pair
locals {
  public_key_file  = "./.security/${var.key_name}.id_rsa.pub"
  private_key_file = "./.security/${var.key_name}.id_rsa"
}

resource "local_file" "my_net_private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.my_net_private_key.private_key_pem
}

# import public key paire to aws
resource "aws_key_pair" "my_net_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.my_net_private_key.public_key_openssh
}

# EC2
# mazon Linux 2 latest image
data "aws_ami" "amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#output "ami_id" {
#  value = data.aws_ami.amazon-linux-image.id
#}

# EC2
resource "aws_instance" "my_net_ec2" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = "t2.micro"
  availability_zone           = var.az_a
  vpc_security_group_ids      = [aws_security_group.my_net_ec2_sg.id]
  subnet_id                   = aws_subnet.my_net_public_subnet.id
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  user_data                   = file("install.sh")
  tags = {
    Name = "my-net-ec2"
  }

  provisioner "file" {
    source      = "config/squid.conf"
    destination = "/tmp/squid.conf"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${local.private_key_file}")
      host        = self.public_ip
    }
  }

}

resource "null_resource" "remote-exec" {
  depends_on = [aws_instance.my_net_ec2]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${local.private_key_file}")
      host        = aws_instance.my_net_ec2.public_ip
    }

    inline = [
      "sudo yum install -y squid",
      "sudo cp /tmp/squid.conf /etc/squid/squid.conf",
      "sudo chown root:squid /etc/squid/squid.conf",
      "sudo chmod o-r /etc/squid/squid.conf",
      "sudo systemctl start squid",
      "sudo systemctl enable squid"
    ]
  }
}