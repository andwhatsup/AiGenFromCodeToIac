resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal infrastructure for this repository:
# The Go program uses AWS SDK to list S3 buckets. To demonstrate AWS access and
# provide a target bucket, we create a single S3 bucket.
resource "aws_s3_bucket" "app" {
  bucket        = "${var.app_name}-${random_id.suffix.hex}"
  force_destroy = true
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
