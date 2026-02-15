resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure:
# This repository is a small Node.js script (no web server / no Dockerfile).
# To keep deployment minimal and broadly compatible (including LocalStack-style
# environments), we provision an S3 bucket that can be used to store artifacts
# (e.g., proxy lists, logs, or packaged code) and output its name.
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
