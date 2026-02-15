resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-${var.s3_bucket_name}-${var.suffix}"
  force_destroy = var.s3_bucket_force_destroy
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "${var.prefix}-delete-bucket-objects-after-${var.s3_bucket_lifecycle_days}-days-${var.suffix}"
    status = "Enabled"

    expiration {
      days = var.s3_bucket_lifecycle_days
    }
  }
}

resource "aws_iam_policy" "this" {
  name = "${var.prefix}-${var.iam_policy_name}-${var.suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

resource "aws_iam_group" "this" {
  name = "${var.prefix}-${var.iam_group_name}-${var.suffix}"
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_user" "this" {
  name = "${var.prefix}-${var.iam_user_name}-${var.suffix}"
}

resource "aws_iam_user_group_membership" "this" {
  user = aws_iam_user.this.name
  groups = [
    aws_iam_group.this.name,
  ]
}

resource "aws_iam_role" "this" {
  name = "${var.prefix}-${var.iam_role_name}-${var.suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.iam_assume_role_service
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "${var.prefix}-${var.iam_role_policy_name}-${var.suffix}"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
