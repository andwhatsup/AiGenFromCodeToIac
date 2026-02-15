# Minimal baseline: S3 bucket for artifacts, IAM role for Flink jobs
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-artifacts"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "flink_job_role" {
  name               = "${var.app_name}-flink-job-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.flink_assume_role_policy.json
  tags = {
    Name = "${var.app_name}-flink-job-role"
  }
}

data "aws_iam_policy_document" "flink_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "flink_job_policy" {
  name   = "${var.app_name}-flink-job-policy-${random_id.suffix.hex}"
  role   = aws_iam_role.flink_job_role.id
  policy = data.aws_iam_policy_document.flink_job_policy.json
}

data "aws_iam_policy_document" "flink_job_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}
