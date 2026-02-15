resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal baseline infrastructure to support deploying the Dash app.
# The repository README describes Elastic Beanstalk deployment driven by EB CLI.
# To keep this Terraform minimal and broadly compatible (including LocalStack-style
# environments), we provision:
# - An S3 bucket for application artifacts (e.g., source bundle) and logs.
# - An IAM role and instance profile that can be used by Elastic Beanstalk EC2 instances.
#
# Note: Creating full Elastic Beanstalk environments via Terraform is possible, but
# often requires additional configuration and can be less deterministic across
# environments. This baseline is enough to support the documented EB CLI workflow.

locals {
  name_prefix = substr(replace(var.app_name, "_", "-"), 0, 32)
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_ec2_role" {
  name               = "${local.name_prefix}-eb-ec2-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach AWS managed policy commonly used by Elastic Beanstalk EC2 instances.
resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "eb_ec2" {
  name = "${local.name_prefix}-eb-ec2-${random_id.suffix.hex}"
  role = aws_iam_role.eb_ec2_role.name
}
