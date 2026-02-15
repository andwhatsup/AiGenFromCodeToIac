resource "aws_iam_role" "glue_crawler_datalake_comprehend" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_glue_crawler_datalake_comprehend.json
  name               = "${local.organization}-glue-crawler-datalake-comprehend"
  path               = "/${local.organization}/"
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}

resource "aws_iam_role" "pipes_pipe_s3_object_created_comprehend" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipes_pipe_s3_object_created_comprehend.json
  name               = "${local.organization}-pipes-pipe-s3-object-created-comprehend"
  path               = "/${local.organization}/"
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}

resource "aws_iam_role" "pipes_pipe_s3_object_created_text" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipes_pipe_s3_object_created_text.json
  name               = "${local.organization}-pipes-pipe-s3-object-created-text"
  path               = "/${local.organization}/"
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}

resource "aws_iam_role" "sfn_state_machine_s3_object_created_comprehend" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_sfn_state_machine_s3_object_created_comprehend.json
  name               = "${local.organization}-sfn-state-machine-s3-object-created-comprehend"
  path               = "/${local.organization}/"
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}

resource "aws_iam_role" "sfn_state_machine_s3_object_created_text" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_sfn_state_machine_s3_object_created_text.json
  name               = "${local.organization}-sfn-state-machine-s3-object-created-text"
  path               = "/${local.organization}/"
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}
