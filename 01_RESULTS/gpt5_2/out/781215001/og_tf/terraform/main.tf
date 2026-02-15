resource "aws_db_instance" "infrafy-postgres-db-instance" {
  allocated_storage        = 20
  engine                   = "postgres"
  engine_version           = "16.1"
  identifier               = "infrafy-postgres-db-instance"
  instance_class           = "db.t3.micro"
  storage_encrypted        = false
  publicly_accessible      = true
  delete_automated_backups = true
  skip_final_snapshot      = true
  db_name                  = var.postgres_db_name
  username                 = var.postgres_username
  password                 = var.postgres_password
  apply_immediately        = true
  multi_az                 = false
  parameter_group_name     = aws_db_parameter_group.default.name
}

resource "aws_db_parameter_group" "default" {
  family = "postgres16"
  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}
