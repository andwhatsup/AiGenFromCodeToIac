resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal infrastructure for this repository:
# The Go program uses AWS SDK to call S3 ListBuckets.
# To run it, you primarily need AWS credentials with s3:ListAllMyBuckets.
# This Terraform creates a demo S3 bucket (optional for the app, but useful to prove access)
# and an IAM user with a least-privilege policy to list buckets.

resource "aws_s3_bucket" "demo" {
  bucket        = "${var.app_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "app" {
  name = "${var.app_name}-user-${random_id.suffix.hex}"
}

resource "aws_iam_access_key" "app" {
  user = aws_iam_user.app.name
}

data "aws_iam_policy_document" "app" {
  statement {
    sid       = "ListAllBuckets"
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  # Optional: allow listing the demo bucket contents (not required for ListBuckets)
  statement {
    sid       = "ListDemoBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.demo.arn]
  }
}

resource "aws_iam_user_policy" "app" {
  name   = "${var.app_name}-policy-${random_id.suffix.hex}"
  user   = aws_iam_user.app.name
  policy = data.aws_iam_policy_document.app.json
}
