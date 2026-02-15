provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "portfolio" {
  name_prefix = "portfolio"

  tags = {
    Name = "portfolio-security-group"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "portfolio" {
  ami           = "ami-006dcf34c09e50022" // Amazon Linux 2 AMI
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.portfolio.id,
  ]
  user_data = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              sudo chown $USER /var/run/docker.sock
              EOF

  tags = {
    Name        = "portfolio-instance"
    Environment = "production"
  }
}

output "public_ip" {
  value = aws_instance.portfolio.public_ip
}
