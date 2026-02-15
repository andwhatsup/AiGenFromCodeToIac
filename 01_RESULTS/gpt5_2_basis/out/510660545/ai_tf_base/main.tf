locals {
  name_prefix = var.app_name
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure for this repository:
# - S3 bucket for Terraform artifacts/state-like storage
# - DynamoDB table for state locking (mirrors Terragrunt remote_state pattern)

resource "aws_s3_bucket" "artifacts" {
  bucket        = lower(replace("${local.name_prefix}-${random_id.suffix.hex}", "_", "-"))
  force_destroy = true
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

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${local.name_prefix}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
