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
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "minecraft" {
  name_prefix = "${var.app_name}-"
  description = "Security group for Minecraft host"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Minecraft"
    from_port   = var.minecraft_port
    to_port     = var.minecraft_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RCON"
    from_port   = var.rcon_port
    to_port     = var.rcon_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RCON Web Admin"
    from_port   = var.rcon_web_port
    to_port     = var.rcon_web_port
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

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    dnf -y update
    dnf -y install docker
    systemctl enable --now docker

    mkdir -p /opt/${var.app_name}/{data,plugins,mc-backups}
    mkdir -p /opt/${var.app_name}/data/{lobby,proxy,rcon}
    mkdir -p /opt/${var.app_name}/plugins/{lobby,proxy}

    cat >/opt/${var.app_name}/docker-compose.yml <<'COMPOSE'
    version: '3.8'

    services:
      lobby:
        image: itzg/minecraft-server
        container_name: lobby
        ports:
          - ${var.minecraft_port}:25565
          - ${var.rcon_port}:25575
        environment:
          MOTD: "Vanilla Minecraft, Chill Vibes Only"
          EULA: "TRUE"
          RCON_PASSWORD: ${var.rcon_password}
          TYPE: ${var.minecraft_type}
          VERSION: ${var.minecraft_version}
          MEMORY: ${var.minecraft_memory}
        restart: always
        volumes:
          - ./data/lobby:/data
          - ./plugins/lobby:/plugins

      rcon:
        image: itzg/rcon
        container_name: rcon
        ports:
          - ${var.rcon_web_port}:4326
          - 4327:4327
        environment:
          RWA_USERNAME: ${var.rcon_web_username}
          RWA_PASSWORD: ${var.rcon_web_password}
          RWA_ADMIN: "TRUE"
          RWA_RCON_HOST: lobby
          RWA_RCON_PASSWORD: ${var.rcon_password}
        volumes:
          - ./data/rcon:/opt/rcon-web-admin/db
        depends_on:
          - lobby

      proxy:
        image: itzg/bungeecord
        container_name: proxy
        environment:
          TYPE: WATERFALL
        volumes:
          - ./plugins/proxy:/plugins
          - ./data/proxy:/config
        depends_on:
          - lobby

      lobby_backup:
        image: itzg/mc-backup
        container_name: lobby_backup
        environment:
          BACKUP_INTERVAL: "2h"
          RCON_HOST: lobby
        volumes:
          - ./data/lobby:/data:ro
          - ./mc-backups:/backups
        depends_on:
          - lobby
    COMPOSE

    curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    cd /opt/${var.app_name}
    /usr/local/bin/docker-compose up -d
  EOF

  tags = {
    Name = "${var.app_name}-host"
  }
}
