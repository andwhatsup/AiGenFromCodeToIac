locals {
  # Keep names deterministic and S3-compliant.
  bucket_name = lower(replace("${var.app_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}", "_", "-"))
}

data "aws_caller_identity" "current" {}

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

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Minimal artifact bucket for the static web app (index.html/style.css/script.js).
# This is a conservative baseline that validates in most environments.
