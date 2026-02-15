data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.app_name}-${random_id.suffix.hex}"
}

# --- Artifact store (S3) ---
resource "aws_s3_bucket" "artifacts" {
  bucket        = lower(replace("${local.name_prefix}-artifacts", "_", "-"))
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --- IAM role for App Runner to pull image from ECR (optional) ---
# If you use a public image (default), this role is not required by App Runner.
# We still create it as a safe stub for future ECR usage.
resource "aws_iam_role" "apprunner_ecr_access" {
  name               = "${local.name_prefix}-apprunner-ecr"
  assume_role_policy = data.aws_iam_policy_document.apprunner_assume.json
}

data "aws_iam_policy_document" "apprunner_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_ecr_access.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# --- Optional RDS backend store (PostgreSQL) ---
# Kept optional to stay minimal and more likely to work in LocalStack-style environments.
# When enabled, it uses the default VPC.

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "rds" {
  count       = var.create_backend_store ? 1 : 0
  name        = "${local.name_prefix}-rds"
  description = "RDS access (PostgreSQL)"
  vpc_id      = data.aws_vpc.default.id

  # NOTE: For a real deployment, restrict this to App Runner VPC connector SG.
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_subnet_group" "default" {
  count      = var.create_backend_store ? 1 : 0
  name       = "${local.name_prefix}-dbsubnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "mlflow" {
  count = var.create_backend_store ? 1 : 0

  identifier             = "${local.name_prefix}-db"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 5432
  publicly_accessible    = true
  skip_final_snapshot    = true
  deletion_protection    = false
  db_subnet_group_name   = aws_db_subnet_group.default[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
}

# --- App Runner service ---
resource "aws_apprunner_service" "mlflow" {
  service_name = local.name_prefix

  source_configuration {
    auto_deployments_enabled = false

    image_repository {
      image_identifier      = var.container_image
      image_repository_type = "ECR_PUBLIC"

      image_configuration {
        port = tostring(var.container_port)

        runtime_environment_variables = {
          # MLflow 2.5+ supports basic auth via --app-name basic-auth
          MLFLOW_TRACKING_USERNAME = var.mlflow_username
          MLFLOW_TRACKING_PASSWORD = var.mlflow_password

          # Store artifacts in S3
          MLFLOW_ARTIFACT_URI = "s3://${aws_s3_bucket.artifacts.bucket}"

          # Optional backend store
          MLFLOW_BACKEND_URI = var.create_backend_store ? "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.mlflow[0].address}:${aws_db_instance.mlflow[0].port}/${var.db_name}" : ""
        }

        # Start MLflow server with basic auth
        start_command = "mlflow server --host 0.0.0.0 --port ${var.container_port} --app-name basic-auth"
      }
    }
  }

  instance_configuration {
    cpu    = "1 vCPU"
    memory = "2 GB"
  }
}
