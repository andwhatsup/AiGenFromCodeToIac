resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_name}-versionedexample"

  versioning {
    enabled = true
  }

  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}

resource "aws_iam_role" "app_role" {
  name = "${var.app_name}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}

resource "aws_iam_policy" "app_policy" {
  name        = "${var.app_name}-s3-policy"
  description = "Allow app to access S3 bucket."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.app_bucket.arn,
        "${aws_s3_bucket.app_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}
