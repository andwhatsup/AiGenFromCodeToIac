resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = coalesce(var.s3_bucket_name, "${var.app_name}-${random_id.suffix.hex}")
}

# Minimal AWS infrastructure inferred from the repo:
# - Kafka Connect uses the S3 sink connector (confluentinc/kafka-connect-s3)
# - Local development uses LocalStack for S3; in AWS we provision a real S3 bucket
#   that can be used as the sink target.
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

# IAM role that can be assumed by ECS tasks (if you later run Kafka Connect/Flink on ECS)
# and grants minimal access to write to the bucket.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-ecs-task-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_write" {
  name        = "${var.app_name}-s3-write-${random_id.suffix.hex}"
  description = "Allow writing objects to the Flink POC S3 bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.data.arn]
      },
      {
        Sid    = "ObjectRW"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["${aws_s3_bucket.data.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_write" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_write.arn
}
