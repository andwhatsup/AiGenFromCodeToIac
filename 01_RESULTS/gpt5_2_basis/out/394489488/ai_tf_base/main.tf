resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.app_name}-${random_id.suffix.hex}"
}

# Artifact store for MLflow
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

# Minimal Aurora Serverless v2 (PostgreSQL) backend store
resource "aws_rds_cluster" "mlflow" {
  cluster_identifier = "${local.name_prefix}-db"

  engine         = "aurora-postgresql"
  engine_version = "15.4"

  database_name   = "mlflow"
  master_username = "mlflow"
  master_password = "mlflowpassword123!"

  # Serverless v2
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "mlflow" {
  identifier         = "${local.name_prefix}-db-1"
  cluster_identifier = aws_rds_cluster.mlflow.id

  engine         = aws_rds_cluster.mlflow.engine
  engine_version = aws_rds_cluster.mlflow.engine_version

  instance_class = "db.serverless"
}

# IAM role for App Runner to access S3
data "aws_iam_policy_document" "apprunner_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apprunner" {
  name               = "${local.name_prefix}-apprunner-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_assume.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "${local.name_prefix}-s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "apprunner_s3" {
  role       = aws_iam_role.apprunner.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# ECR repository to store the container image
resource "aws_ecr_repository" "app" {
  name                 = local.name_prefix
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# App Runner service (expects an image already pushed to ECR)
resource "aws_apprunner_service" "mlflow" {
  service_name = local.name_prefix

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"

      image_configuration {
        port = tostring(var.container_port)

        runtime_environment_variables = {
          PORT                     = tostring(var.container_port)
          MLFLOW_ARTIFACT_URI      = "s3://${aws_s3_bucket.artifacts.bucket}"
          MLFLOW_BACKEND_URI       = "postgresql://${aws_rds_cluster.mlflow.master_username}:${aws_rds_cluster.mlflow.master_password}@${aws_rds_cluster.mlflow.endpoint}:5432/${aws_rds_cluster.mlflow.database_name}"
          MLFLOW_TRACKING_USERNAME = var.mlflow_username
          MLFLOW_TRACKING_PASSWORD = var.mlflow_password
        }
      }
    }
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner.arn
  }
}
