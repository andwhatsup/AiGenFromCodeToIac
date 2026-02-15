locals {
  # This repository builds a small container image intended to run as a Kubernetes CronJob.
  # Since Kubernetes is out of scope for a minimal AWS baseline, we provision a small
  # set of AWS resources that are commonly needed to store artifacts and secrets.
  #
  # The container expects these environment variables at runtime:
  # - DB_HOST, DB_USER, DB_PASS, DB_NAME
  # - FTP_HOST, FTP_USER, FTP_PASS
  #
  # We store placeholders in SSM Parameter Store (SecureString) so operators can
  # populate real values after apply.
  ssm_params = {
    DB_HOST  = "change-me"
    DB_USER  = "change-me"
    DB_PASS  = "change-me"
    DB_NAME  = "nextcloud"
    FTP_HOST = "change-me"
    FTP_USER = "change-me"
    FTP_PASS = "change-me"
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"
  force_destroy = var.artifact_bucket_force_destroy
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

resource "aws_ssm_parameter" "env" {
  for_each = local.ssm_params

  name        = "/${var.app_name}/${each.key}"
  description = "Runtime env var ${each.key} for ${var.app_name}"
  type        = "SecureString"
  value       = each.value

  lifecycle {
    ignore_changes = [value]
  }
}
