resource "aws_s3_bucket" "input_bucket" {
  bucket        = "${var.app_name}-input-${var.aws_region}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-input"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.app_name}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "trigger_dag" {
  function_name    = "${var.app_name}-trigger-dag"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  filename         = "../infra/src/lambda/trigger-dag/index.py"
  source_code_hash = filebase64sha256("../infra/src/lambda/trigger-dag/index.py")
  environment {
    variables = {
      LOG_LEVEL     = "INFO"
      MWAA_ENV_NAME = aws_mwaa_environment.mwaa.name
    }
  }
}

resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_dag.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "input.json"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_dag.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_mwaa_environment" "mwaa" {
  name               = "${var.app_name}-mwaa"
  airflow_version    = "2.9.3"
  environment_class  = "mw1.small"
  execution_role_arn = aws_iam_role.lambda_exec.arn
  source_bucket_arn  = aws_s3_bucket.input_bucket.arn
  dag_s3_path        = "dags/hello-world-dag.py"
  network_configuration {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = data.aws_subnets.default.ids
  }
  webserver_access_mode = "PUBLIC_ONLY"
  tags = {
    Name = "${var.app_name}-mwaa"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}
