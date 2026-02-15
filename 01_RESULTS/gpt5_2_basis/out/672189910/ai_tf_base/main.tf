resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure.
# The repository contains a Dockerfile for a Streamlit app, but building/pushing images
# and running ECS/ALB would require additional CI/CD inputs. To keep this minimal and
# reliably valid, we provision an S3 bucket for artifacts/static assets.
resource "aws_s3_bucket" "artifacts" {
  bucket        = lower(replace("${var.app_name}-${random_id.suffix.hex}", "_", "-"))
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
