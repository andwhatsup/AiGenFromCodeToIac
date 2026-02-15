locals {
  name = var.app_name
}

# Minimal, conservative baseline for this repo:
# - The app is a Streamlit container (Dockerfile exposes 8050).
# - To keep infra minimal and broadly compatible (incl. LocalStack-style envs),
#   we provision an S3 bucket for artifacts/static assets and an ECR repository
#   to push the container image.

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name}-artifacts-"

  tags = {
    Name = "${local.name}-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = local.name
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
