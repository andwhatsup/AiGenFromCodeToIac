resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure:
# This repository is a small Node.js script (no web server / no Dockerfile).
# To keep deployment minimal and broadly compatible (including LocalStack-style
# environments), we provision an S3 bucket that can be used to store artifacts,
# logs, or scraped outputs.

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${random_id.suffix.hex}"
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
