data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2" {
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

resource "aws_security_group" "squid" {
  name_prefix = "${var.app_name}-sg-"
  description = "Security group for Squid proxy EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Squid proxy"
    from_port   = var.squid_port
    to_port     = var.squid_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_proxy_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "squid" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.squid.id]
  associate_public_ip_address = true

  key_name = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail

              yum update -y
              amazon-linux-extras install epel -y || true
              yum install -y squid

              # Minimal open proxy config restricted by security group.
              cat > /etc/squid/squid.conf <<'CONF'
              http_port ${var.squid_port}

              acl localnet src 0.0.0.0/0
              http_access allow localnet
              http_access deny all

              cache deny all
              access_log /var/log/squid/access.log
              cache_log /var/log/squid/cache.log
              CONF

              systemctl enable squid
              systemctl restart squid
              EOF

  tags = {
    Name = "${var.app_name}-ec2"
  }
}
