locals {
  # This repository contains a simple Node.js/Express app (server.js) and a Dockerfile.
  # A minimal, conservative baseline is provided here: an S3 bucket to store build artifacts
  # (e.g., container image metadata, static assets, or CI outputs).
  #
  # If you want a runnable deployment target on AWS, the next step would typically be
  # ECS Fargate + ALB + ECR. That is intentionally omitted to keep the baseline minimal
  # and broadly compatible with LocalStack-style environments.
  artifact_bucket_name = "${var.app_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.id}"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "artifacts" {
  bucket        = local.artifact_bucket_name
  force_destroy = var.artifact_bucket_force_destroy
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
