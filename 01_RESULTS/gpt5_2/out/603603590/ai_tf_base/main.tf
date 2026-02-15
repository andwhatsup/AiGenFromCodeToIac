locals {
  name = var.app_name

  ssh_public_key_effective = coalesce(
    var.ssh_public_key,
    try(file(var.ssh_public_key_path), null)
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

resource "aws_key_pair" "this" {
  count      = local.ssh_public_key_effective == null ? 0 : 1
  key_name   = "${local.name}-key"
  public_key = local.ssh_public_key_effective
}

resource "aws_security_group" "this" {
  name        = "${local.name}-sg"
  description = "Security group for ${local.name} (Kafka + UI + NPM)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kafka UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Proxy Manager HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Proxy Manager Admin"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Proxy Manager HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kafka external listener (as in docker-compose 9093)"
    from_port   = 9093
    to_port     = 9093
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

resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true

  key_name = try(aws_key_pair.this[0].key_name, null)

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf -y update
    dnf -y install docker git

    systemctl enable --now docker
    usermod -aG docker ec2-user || true

    mkdir -p /opt/${local.name}
    cat > /opt/${local.name}/docker-compose.yml <<'COMPOSE'
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
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker:9092,PLAINTEXT_INTERNAL://broker:29092,PLAINTEXT_HOST://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9093
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
    COMPOSE

    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    cd /opt/${local.name}
    /usr/local/bin/docker-compose up -d
  EOF

  tags = {
    Name = local.name
  }
}
