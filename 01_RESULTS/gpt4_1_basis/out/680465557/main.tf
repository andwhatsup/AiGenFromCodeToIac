resource "aws_ecr_repository" "gitops_ecr" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags = {
    Name = "${var.random_prefix}-ecr-${var.random_suffix}"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.random_prefix}-lambda-role-${var.random_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "${var.random_prefix}-lambda-role-${var.random_suffix}"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.random_prefix}-lambda-permissions-${var.random_suffix}"
  description = "Policy for Lambda to access ECR, CloudWatch, IAM, Organizations, and GitHub."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "iam:List*",
          "iam:Get*",
          "organizations:List*",
          "organizations:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "gitops_lambda" {
  function_name = "${var.random_prefix}-${var.random_suffix}"
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:v${var.random_suffix}"
  package_type  = "Image"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
  environment {
    variables = {
      GITHUB_USERNAME = var.github_username
      GITHUB_REPO     = var.github_repo
      GITHUB_TOKEN    = var.github_token
    }
  }
  tags = {
    Name = "${var.random_prefix}-lambda-${var.random_suffix}"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

data "aws_caller_identity" "current" {}
