locals {
  name = var.app_name
}

# Minimal, conservative baseline infrastructure.
# This repository is primarily a Node.js test example (mocha) with a Dockerfile.
# There is no web server/app entrypoint exposed, so we avoid ECS/ALB and instead
# provision a small artifact bucket that can be used by CI/CD pipelines.

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name}-artifacts-"

  force_destroy = true
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

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
