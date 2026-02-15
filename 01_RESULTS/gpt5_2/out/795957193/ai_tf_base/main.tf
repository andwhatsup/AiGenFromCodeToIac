data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.app_name}-sg-"
  description = "Security group for ${var.app_name} Node/Express app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP app port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.ssh_key_name == null ? [] : [1]
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  key_name = var.ssh_key_name

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail

              dnf -y update
              dnf -y install nodejs

              mkdir -p /opt/${var.app_name}
              cat > /opt/${var.app_name}/server.js <<'JS'
              const express = require('express')
              const app = express()
              const port = 3000

              app.get('/', (req, res) => {
                  res.send('Hello World!')
              })

              app.listen(port, () => {
                  console.log('Example app listening on port ' + port)
              })
              JS

              cat > /opt/${var.app_name}/package.json <<'JSON'
              {
                "name": "${var.app_name}",
                "version": "1.0.0",
                "main": "server.js",
                "license": "ISC",
                "dependencies": {
                  "express": "^4.19.2"
                },
                "scripts": {
                  "start": "node server.js"
                }
              }
              JSON

              cd /opt/${var.app_name}
              npm install --omit=dev

              cat > /etc/systemd/system/${var.app_name}.service <<'UNIT'
              [Unit]
              Description=${var.app_name} Node app
              After=network.target

              [Service]
              Type=simple
              WorkingDirectory=/opt/${var.app_name}
              ExecStart=/usr/bin/node /opt/${var.app_name}/server.js
              Restart=always
              RestartSec=5
              Environment=NODE_ENV=production

              [Install]
              WantedBy=multi-user.target
              UNIT

              systemctl daemon-reload
              systemctl enable --now ${var.app_name}.service
              EOF

  tags = {
    Name = "${var.app_name}-ec2"
  }
}
