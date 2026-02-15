data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.app_name}-db-subnets-${random_id.suffix.hex}"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.app_name}-db-subnets"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.app_name}-db-sg-${random_id.suffix.hex}"
  description = "Security group for ${var.app_name} RDS MySQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-db-sg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.app_name}-mysql-${random_id.suffix.hex}"

  engine         = "mysql"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = var.db_publicly_accessible

  skip_final_snapshot = true
  deletion_protection = false

  apply_immediately = true

  tags = {
    Name = "${var.app_name}-mysql"
  }
}
