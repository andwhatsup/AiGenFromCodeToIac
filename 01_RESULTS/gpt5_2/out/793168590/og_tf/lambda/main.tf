provider "aws" {
  region = "eu-west-1"
}

resource "aws_lambda_function" "example" {
  function_name = "example_lambda_function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  # Assuming the lambda code is zipped and stored as lambda_function.zip in the same directory as Terraform configuration
  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

  # IAM role with basic Lambda execution permissions
  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_sagemaker_invoke" {
  name        = "lambda_sagemaker_invoke"
  description = "Allows lambda to invoke SageMaker endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sagemaker:InvokeEndpoint",
        Resource = "arn:aws:sagemaker:eu-west-1:511771194412:endpoint/hello-world-endpoint"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sagemaker_invoke.arn
}