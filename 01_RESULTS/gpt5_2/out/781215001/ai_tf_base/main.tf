data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "postgres" {
  name_prefix = "${var.app_name}-postgres-"
  description = "Allow Postgres access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "PostgreSQL"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.app_name}-db-"
  subnet_ids  = data.aws_subnets.default.ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier_prefix = "${var.app_name}-pg-"

  engine         = "postgres"
  engine_version = "16.2"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  publicly_accessible = var.db_publicly_accessible

  skip_final_snapshot = true
  deletion_protection = false

  apply_immediately = true

  tags = {
    Name = "${var.app_name}-postgres"
  }
}
