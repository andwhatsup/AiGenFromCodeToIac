data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Minimal, conservative baseline for this repo:
# - S3 bucket for Prefect flow storage/artifacts (the repo references an S3 storage block)
# - Optional ECR repository for a custom Prefect agent image (repo is about running agent on ECS)
# This avoids VPC/ECS/ALB complexity while still providing core AWS primitives.

resource "aws_s3_bucket" "prefect_artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "prefect_artifacts" {
  bucket = aws_s3_bucket.prefect_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prefect_artifacts" {
  bucket = aws_s3_bucket.prefect_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_ecr_repository" "agent" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "agent" {
  count      = var.create_ecr_repository ? 1 : 0
  repository = aws_ecr_repository.agent[0].name

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
