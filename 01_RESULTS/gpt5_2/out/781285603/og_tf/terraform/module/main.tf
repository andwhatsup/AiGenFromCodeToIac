# main.tf
resource "aws_iam_role" "role" {
  name = "prod-ci-role-${var.name_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "*"
      },
      Action = "sts:AssumeRole",
    }]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "prod-ci-policy-${var.name_suffix}"
  description = "Policy allowing users/entities to assume the role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sts:AssumeRole",
      Resource = aws_iam_role.role.arn,
    }]
  })
}

resource "aws_iam_group" "group" {
  name = "prod-ci-group-${var.name_suffix}"
}

resource "aws_iam_group_policy_attachment" "policy_attachment" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "user" {
  name = "prod-ci-user-${var.name_suffix}"

}

resource "aws_iam_user_group_membership" "example1" {
  user = aws_iam_user.user.name

  groups = [
    aws_iam_group.group.name,
  ]
}