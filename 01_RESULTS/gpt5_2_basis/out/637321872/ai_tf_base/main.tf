locals {
  common_tags = merge(
    {
      Application = var.app_name
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Amazon Linux 2 (x86_64) - widely available and stable for simple bootstrapping.
# If you prefer AL2023, swap the filter.
data "aws_ami" "amazon_linux2" {
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
  description = "Security group for Squid proxy"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Squid proxy"
    from_port   = var.squid_port
    to_port     = var.squid_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Optional SSH access from the same allowed CIDR.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "squid" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.squid.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail

              timedatectl set-timezone Asia/Tokyo || true

              yum update -y
              yum install -y squid

              cat > /etc/squid/squid.conf <<'SQUIDCONF'
              acl localnet src ${var.allowed_cidr}

              acl SSL_ports port 443
              acl Safe_ports port 80
              acl Safe_ports port 443
              acl CONNECT method CONNECT

              http_access deny !Safe_ports
              http_access deny CONNECT !SSL_ports

              http_access allow localnet
              http_access allow localhost
              http_access deny all

              http_port ${var.squid_port}

              coredump_dir /var/spool/squid

              refresh_pattern ^ftp:           1440    20%     10080
              refresh_pattern ^gopher:        1440    0%      1440
              refresh_pattern -i (/cgi-bin/|\\?) 0     0%      0
              refresh_pattern .               0       20%     4320

              visible_hostname unknown
              SQUIDCONF

              systemctl enable squid
              systemctl restart squid
              EOF

  tags = merge(local.common_tags, { Name = "${var.app_name}-squid" })
}
