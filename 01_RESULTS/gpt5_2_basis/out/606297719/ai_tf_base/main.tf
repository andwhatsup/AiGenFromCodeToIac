resource "aws_s3_bucket" "prefect_storage" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.app_name}-storage"
  }
}

resource "aws_s3_bucket_versioning" "prefect_storage" {
  bucket = aws_s3_bucket.prefect_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prefect_storage" {
  bucket = aws_s3_bucket.prefect_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "prefect_storage" {
  bucket = aws_s3_bucket.prefect_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
