resource "aws_ecr_repository" "lambda_repo" {
  name                 = "${var.app_name}-lambda-repo"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.app_name}-lambda-repo"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-lambda-exec-role"
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
    Name = "${var.app_name}-lambda-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "app_lambda" {
  function_name = "${var.app_name}-lambda"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  environment {
    variables = {
      # Add environment variables as needed
    }
  }
  tags = {
    Name = "${var.app_name}-lambda"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}
