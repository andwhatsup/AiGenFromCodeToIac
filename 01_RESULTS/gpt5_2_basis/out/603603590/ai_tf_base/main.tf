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

resource "aws_security_group" "kafka_host" {
  name_prefix = "${var.app_name}-sg-"
  description = "Security group for single-node Kafka docker host"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Kafka UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ui_cidr]
  }

  ingress {
    description = "Nginx Proxy Manager HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ui_cidr]
  }

  ingress {
    description = "Nginx Proxy Manager Admin"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ui_cidr]
  }

  ingress {
    description = "Nginx Proxy Manager HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ui_cidr]
  }

  ingress {
    description = "Kafka external listener (as in docker-compose 9093)"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ui_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "this" {
  count      = var.ssh_public_key != "" ? 1 : 0
  key_name   = "${var.app_name}-key"
  public_key = var.ssh_public_key
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    dnf -y update
    dnf -y install docker
    systemctl enable --now docker

    # Install docker compose plugin
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    mkdir -p /opt/${var.app_name}
    cat > /opt/${var.app_name}/docker-compose.yml <<'YAML'
    version: "3"

    services:
      zookeeper:
        image: confluentinc/cp-zookeeper:7.3.0
        container_name: zookeeper
        environment:
          ZOOKEEPER_CLIENT_PORT: 2181
          ZOOKEEPER_TICK_TIME: 2000
        networks:
          - kafka-network

      broker:
        image: confluentinc/cp-kafka:7.3.0
        container_name: broker
        depends_on:
          - zookeeper
        ports:
          - "9093:9093"
        environment:
          KAFKA_BROKER_ID: 1
          KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
          KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
          # Advertise the instance public IP for the host listener
          KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://broker:9092,PLAINTEXT_INTERNAL://broker:29092,PLAINTEXT_HOST://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9093"
          KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
          KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
          KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
        networks:
          - kafka-network

      kafka-ui:
        image: provectuslabs/kafka-ui
        container_name: kafka-ui
        ports:
          - "8080:8080"
        restart: always
        environment:
          KAFKA_CLUSTERS_0_NAME: local
          KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: broker:9092
          KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
        depends_on:
          - broker
          - zookeeper
        networks:
          - kafka-network

      proxy-manager:
        image: 'jc21/nginx-proxy-manager:latest'
        restart: unless-stopped
        ports:
          - '80:80'
          - '81:81'
          - '443:443'
        volumes:
          - ./data:/data
          - ./letsencrypt:/etc/letsencrypt
        networks:
          - kafka-network

    networks:
      kafka-network:
        driver: bridge
    YAML

    cd /opt/${var.app_name}
    docker compose up -d
  EOT
}

resource "aws_instance" "kafka_host" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.kafka_host.id]
  associate_public_ip_address = true

  key_name = var.ssh_public_key != "" ? aws_key_pair.this[0].key_name : null

  user_data = local.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tags = {
    Name = "${var.app_name}-host"
  }
}
