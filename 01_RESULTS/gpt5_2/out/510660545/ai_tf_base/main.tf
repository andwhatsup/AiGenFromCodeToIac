locals {
  # If a bucket name is not provided, generate a deterministic-ish name.
  # Note: S3 bucket names must be globally unique; override via var.state_bucket_name if needed.
  generated_state_bucket_name = lower(replace("${var.app_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-tfstate", "_", "-"))

  state_bucket_name = coalesce(var.state_bucket_name, local.generated_state_bucket_name)
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "tf_state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = local.state_bucket_name

  # Keep minimal; additional hardening is done via separate resources.
}

resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_locks" {
  count        = var.create_lock_table ? 1 : 0
  name         = "${var.app_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
