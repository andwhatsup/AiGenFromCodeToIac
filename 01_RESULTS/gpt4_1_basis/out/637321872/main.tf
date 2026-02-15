data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "squid_proxy" {
  name        = "squid-proxy-sg"
  description = "Allow inbound access to Squid proxy"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow Squid proxy from allowed IP"
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "squid_proxy" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.squid_proxy.id]
  key_name               = var.key_name

  user_data = file("${path.module}/install.sh")

  tags = {
    Name = "squid-proxy"
  }

  provisioner "file" {
    source      = "${path.module}/../source/config/squid.conf"
    destination = "/tmp/squid.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/squid.conf /etc/squid/squid.conf",
      "sudo systemctl restart squid || sudo service squid restart"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/../source/.security/my-net-keypair.id_rsa")
      host        = self.public_ip
    }
  }
}
