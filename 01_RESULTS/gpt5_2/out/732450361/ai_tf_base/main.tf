resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure for this repository.
# The repo contains a small Flask app (app.py) but no container/build artifacts.
# To keep deployment minimal and broadly compatible, we provision an S3 bucket
# that can be used for artifacts/static assets and as a simple proof of AWS access.
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

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
