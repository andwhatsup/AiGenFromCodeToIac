resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal infra inferred from repo: Python script ingests fake data to an S3 bucket.
# Create a bucket to receive ingested data.
resource "aws_s3_bucket" "data" {
  bucket        = lower(replace("${var.app_name}-${random_id.suffix.hex}", "_", "-"))
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
