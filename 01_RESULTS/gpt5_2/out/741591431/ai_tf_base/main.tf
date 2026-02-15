resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal, conservative baseline for this repository:
# - The app is a React application (create-react-app) and can be hosted as static assets.
# - We provision an S3 bucket suitable for hosting build artifacts/static site.
# - (Optional) website hosting can be enabled later; we keep it minimal for broad compatibility.

resource "aws_s3_bucket" "app" {
  bucket        = "${var.app_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
