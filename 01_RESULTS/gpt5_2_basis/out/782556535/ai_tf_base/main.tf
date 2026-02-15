resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = lower(replace(var.app_name, "_", "-"))
}

# Minimal infra for this repository: an S3 bucket used by the terratest examples.
resource "aws_s3_bucket" "app" {
  bucket        = "${local.name_prefix}-${random_id.suffix.hex}"
  force_destroy = true
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
