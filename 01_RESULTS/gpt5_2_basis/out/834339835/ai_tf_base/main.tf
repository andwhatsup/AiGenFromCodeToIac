locals {
  # Keep names deterministic and S3-compliant.
  bucket_name = lower(replace("${var.app_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.id}", "_", "-"))
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = var.bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Minimal artifact bucket for the static app/container build outputs.
# This repo contains a static HTML/CSS/JS app and a Dockerfile (nginx).
# We keep infra minimal and broadly compatible (no CloudFront/ALB/ECS).
