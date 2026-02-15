resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifact" {
  bucket = coalesce(var.artifact_bucket_name, "ai-basis-artifacts-${random_id.suffix.hex}")
  tags = {
    Name        = "ai-basis-artifacts"
    Environment = "dev"
  }
}

resource "aws_iam_role" "basic" {
  name = "ai-basis-basic-role-${random_id.suffix.hex}"
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
    Name        = "ai-basis-basic-role"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "basic_policy" {
  name        = "ai-basis-basic-policy-${random_id.suffix.hex}"
  description = "Basic policy for S3 access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Effect = "Allow"
      Resource = [
        aws_s3_bucket.artifact.arn,
        "${aws_s3_bucket.artifact.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_attach" {
  role       = aws_iam_role.basic.name
  policy_arn = aws_iam_policy.basic_policy.arn
}
