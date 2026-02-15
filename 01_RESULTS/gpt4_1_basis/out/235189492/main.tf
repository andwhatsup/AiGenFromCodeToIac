resource "aws_iam_role" "lambda_exec" {
  name               = var.lambda_role_name
  assume_role_policy = file("${path.module}/../assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-invoke-policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "iterator_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main"
  runtime       = "go1.x"
  filename      = "lambda.zip" # You must build and provide this artifact
  environment {
    variables = {
      REGION = var.region
      LAMBDA = var.target_lambda_arn
    }
  }
}

resource "aws_sfn_state_machine" "iterator_step_function" {
  name     = "iterator-step-function"
  role_arn = aws_iam_role.lambda_exec.arn
  definition = templatefile("${path.module}/../definition.json", {
    iterator_arn = aws_lambda_function.iterator_lambda.arn
  })
}
