resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  input_bucket_name  = "${var.app_name}-input-${random_id.suffix.hex}"
  output_bucket_name = "${var.app_name}-output-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "input" {
  bucket        = local.input_bucket_name
  force_destroy = true
  tags = {
    Name = "${var.app_name}-input"
  }
}

resource "aws_s3_bucket" "output" {
  bucket        = local.output_bucket_name
  force_destroy = true
  tags = {
    Name = "${var.app_name}-output"
  }
}

resource "aws_sqs_queue" "input" {
  name = "${var.app_name}-input-queue-${random_id.suffix.hex}"
}

resource "aws_sqs_queue" "output" {
  name = "${var.app_name}-output-queue-${random_id.suffix.hex}"
}

resource "aws_iam_role" "step_function" {
  name               = "${var.app_name}-step-function-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume_role_policy.json
}

data "aws_iam_policy_document" "step_function_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "step_function_policy" {
  name   = "${var.app_name}-step-function-policy-${random_id.suffix.hex}"
  role   = aws_iam_role.step_function.id
  policy = data.aws_iam_policy_document.step_function_policy.json
}

data "aws_iam_policy_document" "step_function_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.input.arn,
      "${aws_s3_bucket.input.arn}/*",
      aws_s3_bucket.output.arn,
      "${aws_s3_bucket.output.arn}/*"
    ]
  }
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.input.arn,
      aws_sqs_queue.output.arn
    ]
  }
  statement {
    actions = [
      "comprehend:Detect*",
      "comprehend:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_sfn_state_machine" "comprehend" {
  name       = "${var.app_name}-comprehend-${random_id.suffix.hex}"
  role_arn   = aws_iam_role.step_function.arn
  definition = file("${path.module}/../state_machine/S3ObjectCreatedText.json")
}

resource "aws_sfn_state_machine" "datalake" {
  name       = "${var.app_name}-datalake-${random_id.suffix.hex}"
  role_arn   = aws_iam_role.step_function.arn
  definition = file("${path.module}/../state_machine/S3ObjectCreatedComprehend.json")
}

resource "aws_s3_bucket_notification" "input" {
  bucket = aws_s3_bucket.input.id
  queue {
    queue_arn     = aws_sqs_queue.input.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "text/"
  }
}

resource "aws_s3_bucket_notification" "output" {
  bucket = aws_s3_bucket.output.id
  queue {
    queue_arn     = aws_sqs_queue.output.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "comprehend/"
  }
}
