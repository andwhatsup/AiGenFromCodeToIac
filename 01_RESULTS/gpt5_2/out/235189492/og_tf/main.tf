provider "aws" {}

resource "aws_iam_role" "iterator" {
  name               = "hfl-iterator"
  assume_role_policy = file("${path.module}/assume_role_policy.json")
}

resource "aws_lambda_function" "iterator" {
  function_name = "hfl-iterator"
  role          = aws_iam_role.iterator.arn
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  handler       = "bootstrap"
  runtime       = "provided.al2"
  timeout       = 5

  environment {
    variables = {
      "LAMBDA" = var.target_lambda
      "REGION" = "us-west-2"
    }
  }
}

resource "aws_sfn_state_machine" "hfl" {
  name     = "hfl-state-machine"
  role_arn = aws_iam_role.hfl-sfn.arn

  definition = templatefile("${path.module}/definition.json", {
    iterator_arn = aws_lambda_function.iterator.arn
  })
  depends_on = [
  aws_lambda_function.iterator]
}

resource "aws_iam_role_policy" "hfl" {
  name   = "hfl-iterator"
  role   = aws_iam_role.iterator.id
  policy = <<EOP
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction"
        ],
        "Resource": "${var.target_lambda}"
    }
  ]
}
EOP
}

resource "aws_iam_role" "hfl-sfn" {
  name = "hfl-sfn"

  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role_policy_document.json
}

data "aws_iam_policy_document" "sfn_assume_role_policy_document" {

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "states.us-west-2.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "hfl-lambda-execution" {
  name = "hfl-lambda-execution"
  role = aws_iam_role.hfl-sfn.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction",
        "states:StartExecution"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
