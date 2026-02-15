data "aws_caller_identity" "current" {}

# Minimal baseline infrastructure for this repository.
# The upstream project is a Terraform module that provisions FreeIPA servers
# in an existing COOL shared services environment. Since that environment
# depends on multiple remote states and pre-existing networking, this baseline
# creates a small, safe set of AWS resources that can be validated/applied
# in most accounts (including LocalStack-style environments).

resource "aws_s3_bucket" "artifacts" {
  # bucket_prefix max length is 37. Keep a stable, short prefix and rely on the
  # provider to append a unique suffix.
  bucket_prefix = "freeipa-artifacts-"
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

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Example IAM role/policy stub that could be used by automation to read/write
# artifacts in the bucket.
resource "aws_iam_role" "artifact_writer" {
  # name_prefix max length is 38.
  name_prefix = "freeipa-art-wr-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "artifact_writer" {
  statement {
    sid     = "ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.artifacts.arn
    ]
  }

  statement {
    sid    = "ObjectRW"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "artifact_writer" {
  # name_prefix max length is 38.
  name_prefix = "freeipa-art-wr-"
  policy      = data.aws_iam_policy_document.artifact_writer.json
}

resource "aws_iam_role_policy_attachment" "artifact_writer" {
  role       = aws_iam_role.artifact_writer.name
  policy_arn = aws_iam_policy.artifact_writer.arn
}
