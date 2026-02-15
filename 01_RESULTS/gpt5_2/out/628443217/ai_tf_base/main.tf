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
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.app_name}-web-"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_ingress_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              yum update -y
              timedatectl set-timezone Asia/Tokyo
              amazon-linux-extras install -y nginx1
              amazon-linux-extras install -y php8.2
              echo '<?php echo "Request from IP: ".$_SERVER["REMOTE_ADDR"]." at ".date(DATE_ATOM); ?>' > /usr/share/nginx/html/index.php
              sed -i -e "s/^expose_php = On/expose_php = Off/" -e "s/^;date.timezone =/date.timezone = Asia\\/Tokyo/" /etc/php.ini
              echo 'server_tokens off;' > /etc/nginx/conf.d/default.conf
              systemctl start php-fpm
              systemctl start nginx
              systemctl enable php-fpm
              systemctl enable nginx
              EOF

  tags = {
    Name = "${var.app_name}-web"
  }
}
