resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_iam_user" "example" {
  name = "go-user-${random_string.suffix.result}"
}

resource "aws_iam_access_key" "example" {
  user = aws_iam_user.example.name
}

resource "aws_iam_policy" "example" {
  name = "s3-list-${random_string.suffix.result}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = [
          "*",
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "example" {
  user       = aws_iam_user.example.name
  policy_arn = aws_iam_policy.example.arn
}

resource "null_resource" "example" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "export AWS_ACCESS_KEY_ID=${aws_iam_access_key.example.id}" > terraform.tmp
      echo "export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.example.secret}" >> terraform.tmp
      echo "export AWS_REGION=${data.aws_region.current.name}" >> terraform.tmp
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f terraform.tmp
    EOT
  }
}
