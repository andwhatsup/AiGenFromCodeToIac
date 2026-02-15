resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "workshop" {
  bucket        = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "workshop" {
  bucket = aws_s3_bucket.workshop.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "workshop" {
  bucket = aws_s3_bucket.workshop.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "workshop" {
  bucket = aws_s3_bucket.workshop.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "workshop" {
  bucket = aws_s3_bucket.workshop.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "sample_image" {
  bucket       = aws_s3_bucket.workshop.id
  key          = "images/lp1.jpeg"
  content_type = "image/jpeg"

  # Placeholder content so the configuration validates without depending on local files.
  content = "placeholder"

  depends_on = [aws_s3_bucket_ownership_controls.workshop]
}
