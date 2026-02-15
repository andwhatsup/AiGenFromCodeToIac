resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = coalesce(var.s3_bucket_name, "${var.app_name}-${random_id.suffix.hex}")
}

resource "aws_s3_bucket" "data" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Minimal IAM role/policy stub that could be used by a future compute runtime (Lambda/ECS/EC2)
# to write objects into the bucket.
resource "aws_iam_role" "writer" {
  name = "${var.app_name}-s3-writer-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "writer" {
  name        = "${var.app_name}-s3-writer-${random_id.suffix.hex}"
  description = "Allow writing objects to the ETL S3 bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteToBucket"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "${aws_s3_bucket.data.arn}/*"
        ]
      },
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "writer" {
  role       = aws_iam_role.writer.name
  policy_arn = aws_iam_policy.writer.arn
}
