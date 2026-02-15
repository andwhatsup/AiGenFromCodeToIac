# Minimal baseline: S3 bucket for artifacts, IAM role/policy stubs

resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${random_pet.bucket_name.id}"
  force_destroy = true
  tags = {
    Name = var.app_name
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name = var.app_name
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_policy" "assume_role_policy" {
  name        = "${var.app_name}-assume-role-policy"
  description = "Allow assuming the ${var.app_name}-role."
  policy      = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "assume_role_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.assume_role_policy.arn
}
