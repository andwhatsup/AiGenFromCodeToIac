resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # In real AWS, bucket names must be globally unique.
  # Keep the default bucket name from the app, but add a suffix to avoid collisions.
  effective_bucket_name = "${var.bucket_name}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "app" {
  bucket = local.effective_bucket_name
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
