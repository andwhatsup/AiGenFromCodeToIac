resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-artifacts"
  }
}


resource "aws_iam_role" "epicac" {
  name               = "${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name = "${var.app_name}-role"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "epicac_policy" {
  name        = "${var.app_name}-policy"
  description = "Policy for cross-account access demo."
  policy      = data.aws_iam_policy_document.epicac_policy.json
}

data "aws_iam_policy_document" "epicac_policy" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.epicac.name
  policy_arn = aws_iam_policy.epicac_policy.arn
}
