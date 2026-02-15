resource "aws_s3_bucket" "main" {
  bucket        = lower("${data.aws_caller_identity.main.account_id}-${local.organization}")
  force_destroy = true
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}
