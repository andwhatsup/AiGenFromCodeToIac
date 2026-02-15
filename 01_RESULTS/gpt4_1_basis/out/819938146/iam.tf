resource "aws_iam_role" "vault_app" {
  name = "${var.app_name}-vault-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = {
    Name = "${var.app_name}-vault-app-role"
  }
}

resource "aws_iam_policy" "vault_app_policy" {
  name        = "${var.app_name}-vault-app-policy"
  description = "Policy for Vault app minimal access."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault_app_attach" {
  role       = aws_iam_role.vault_app.name
  policy_arn = aws_iam_policy.vault_app_policy.arn
}
