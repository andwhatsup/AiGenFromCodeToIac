resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure.
# The repository contains only a Dockerfile that pins a Renovate image and a short README.
# There is no application code or runtime configuration to infer a web service.
# To keep this deployable and validate reliably, we provision an S3 bucket that can be used
# for artifacts (e.g., extracted metadata, logs, build outputs).

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
