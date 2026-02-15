resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure for this repository.
# The repo is primarily Ansible + scripts to provision a Rancher/RKE cluster.
# No application runtime (Docker/Lambda/etc.) is defined here, so we create a
# small, safe set of AWS resources that validate and can be used as an artifact
# bucket for cluster configs, kubeconfig backups, etc.

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
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
