data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Minimal baseline infrastructure:
# - S3 bucket to store build artifacts/configs (optional but useful)
# - IAM role + policy that can be used as the *source* role for EKS Pod Identity
#   (the repo demonstrates cross-account role assumption; the destination role is in another account)

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"
  force_destroy = var.artifact_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "pod_identity_source" {
  name_prefix = "${var.app_name}-podid-src-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# Minimal permissions for the example app to call S3 ListBuckets.
# In real usage, you would typically grant only what the source role needs
# (often nothing beyond the ability to call STS, since the destination role
# provides the actual permissions).
resource "aws_iam_role_policy" "pod_identity_source_s3_list" {
  name_prefix = "${var.app_name}-s3list-"
  role        = aws_iam_role.pod_identity_source.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}
