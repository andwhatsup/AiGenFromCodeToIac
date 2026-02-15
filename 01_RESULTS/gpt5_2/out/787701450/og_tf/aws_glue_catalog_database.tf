resource "aws_glue_catalog_database" "datalake_comprehend" {
  name = "${local.organization}-datalake-comprehend"
  tags = {
    account_arn    = data.aws_caller_identity.main.arn
    account_id     = data.aws_caller_identity.main.account_id
    organization   = local.organization
    region         = data.aws_region.main.name
    s3_bucket      = aws_s3_bucket.main.bucket
    s3_target_path = "s3://${aws_s3_bucket.main.id}/${aws_s3_object.datalake_comprehend.key}"
    workspace      = terraform.workspace
  }
}
