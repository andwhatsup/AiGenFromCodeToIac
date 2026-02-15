resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal, conservative deployment target for a static React frontend:
# - S3 bucket to host build artifacts (private by default)
# - Public access blocked (safe baseline)
# - Versioning enabled
# - Output bucket name for CI/CD to upload build/ artifacts
resource "aws_s3_bucket" "frontend_artifacts" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "frontend_artifacts" {
  bucket = aws_s3_bucket.frontend_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_artifacts" {
  bucket = aws_s3_bucket.frontend_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
