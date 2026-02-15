resource "aws_security_group" "rds" {
  name   = "rds"
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.task_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "mehlj-pipeline" {
  name       = "mehlj-pipeline"
  subnet_ids = aws_subnet.private.*.id
}

# enable logging on all instances
resource "aws_db_parameter_group" "mehlj-pipeline" {
  name   = "mehlj-pipeline"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  arn = "arn:aws:secretsmanager:us-east-1:252267185844:secret:mehlj_lab_creds-j5VElQ"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

resource "aws_db_instance" "mehlj-pipeline" {
  identifier             = "mehlj-pipeline"
  db_name                = "ecspoc"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.1"
  username               = "dbuser"
  password               = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["vault"]
  db_subnet_group_name   = aws_db_subnet_group.mehlj-pipeline.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.mehlj-pipeline.name
  skip_final_snapshot    = true
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.mehlj-pipeline.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mehlj-pipeline.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.mehlj-pipeline.username
  sensitive   = true
}