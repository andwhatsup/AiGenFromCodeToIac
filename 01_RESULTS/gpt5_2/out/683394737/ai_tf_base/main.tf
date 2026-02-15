data "aws_caller_identity" "current" {}

resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal, safe baseline inferred from repo:
# - Static website assets exist under Frontend/
# - Dockerfile builds an Apache httpd image that serves those assets
# For a minimal deployable target that validates easily, we provision an S3 bucket
# to store artifacts/static assets (optionally can be used for static website hosting).

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${data.aws_caller_identity.current.account_id}-${random_id.suffix.hex}"
  force_destroy = var.artifact_bucket_force_destroy
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
