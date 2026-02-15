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
  description = "Allow inbound Postgres"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
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
  name       = "${var.app_name}-db-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.app_name}-db-subnets"
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

# Optional: a small bucket for artifacts/static files (safe baseline)
resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"

  tags = {
    Name = "${var.app_name}-artifacts"
  }
}
