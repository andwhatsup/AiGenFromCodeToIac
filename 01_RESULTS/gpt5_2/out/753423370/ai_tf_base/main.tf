resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.app_name}-${var.environment}"
}

# Minimal infrastructure for a static React frontend:
# - S3 bucket to host build artifacts (static website hosting)
# This keeps the deployment simple and validates in most environments.
resource "aws_s3_bucket" "site" {
  bucket        = lower(replace("${local.name_prefix}-${random_id.suffix.hex}", "_", "-"))
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Keep bucket private by default; users can front it with CloudFront/OAC later.
# This object is a placeholder to prove the bucket can store artifacts.
resource "aws_s3_object" "placeholder" {
  bucket       = aws_s3_bucket.site.id
  key          = "README.txt"
  content      = "Upload your React build output (e.g., build/) to this bucket."
  content_type = "text/plain"
}
