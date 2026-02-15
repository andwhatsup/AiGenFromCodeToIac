resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "workshop" {
  bucket        = "${var.bucket_name_prefix}-${random_id.suffix.hex}"
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

resource "aws_s3_object" "sample_image" {
  bucket       = aws_s3_bucket.workshop.id
  key          = "imagenes/lp1.jpeg"
  source       = "${path.module}/../images/lp1.jpeg"
  content_type = "image/jpeg"

  etag = filemd5("${path.module}/../images/lp1.jpeg")

  depends_on = [aws_s3_bucket_public_access_block.workshop]
}
