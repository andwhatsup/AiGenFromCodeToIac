resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-exec"
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
    Name = var.lambda_function_name
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.lock_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "lock_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}

resource "aws_lambda_function" "delta_optimize_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout

  filename         = "bootstrap.zip" # You must upload this artifact manually or automate it
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE    = aws_dynamodb_table.lock_table.name
      DATALAKE_LOCATION = "<YOUR_DELTA_LAKE_S3_PATH>" # Set this appropriately
    }
  }

  tags = {
    Name = var.lambda_function_name
  }
}
