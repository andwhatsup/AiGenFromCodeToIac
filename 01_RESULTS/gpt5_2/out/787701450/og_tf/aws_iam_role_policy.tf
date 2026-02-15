resource "aws_iam_role_policy" "glue_crawler_datalake_comprehend" {
  policy = data.aws_iam_policy_document.glue_crawler_datalake_comprehend.json
  role   = aws_iam_role.glue_crawler_datalake_comprehend.id
}

resource "aws_iam_role_policy" "pipes_pipe_s3_object_created_comprehend" {
  policy = data.aws_iam_policy_document.pipes_pipe_s3_object_created_comprehend.json
  role   = aws_iam_role.pipes_pipe_s3_object_created_comprehend.id
}

resource "aws_iam_role_policy" "pipes_pipe_s3_object_created_text" {
  policy = data.aws_iam_policy_document.pipes_pipe_s3_object_created_text.json
  role   = aws_iam_role.pipes_pipe_s3_object_created_text.id
}

resource "aws_iam_role_policy" "sfn_state_machine_s3_object_created_comprehend" {
  policy = data.aws_iam_policy_document.sfn_state_machine_s3_object_created_comprehend.json
  role   = aws_iam_role.sfn_state_machine_s3_object_created_comprehend.id
}

resource "aws_iam_role_policy" "sfn_state_machine_s3_object_created_text" {
  policy = data.aws_iam_policy_document.sfn_state_machine_s3_object_created_text.json
  role   = aws_iam_role.sfn_state_machine_s3_object_created_text.id
}
