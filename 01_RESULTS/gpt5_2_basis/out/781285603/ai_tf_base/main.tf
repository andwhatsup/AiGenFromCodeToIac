locals {
  # Ensure names are deterministic and within IAM limits.
  base_name = var.name_suffix != "" ? "${var.app_name}-${var.name_suffix}" : var.app_name
}

data "aws_caller_identity" "current" {}

# Trust policy: allow principals in the same AWS account to assume the role.
# This is intentionally broad to match the challenge requirement.
resource "aws_iam_role" "assumable" {
  name = local.base_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAssumeFromSameAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # No permissions attached to the role (as requested).
}

# Policy that allows assuming the above role.
resource "aws_iam_policy" "assume_role" {
  name        = local.base_name
  description = "Allows sts:AssumeRole on ${aws_iam_role.assumable.name}."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeRole"
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = aws_iam_role.assumable.arn
      }
    ]
  })
}

resource "aws_iam_group" "group" {
  name = local.base_name
}

resource "aws_iam_group_policy_attachment" "group_assume_role" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.assume_role.arn
}

resource "aws_iam_user" "user" {
  name = local.base_name
}

resource "aws_iam_user_group_membership" "user_membership" {
  user   = aws_iam_user.user.name
  groups = [aws_iam_group.group.name]
}
