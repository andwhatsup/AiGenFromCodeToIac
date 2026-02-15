resource "aws_pipes_pipe" "sfn_state_machine_s3_object_created_comprehend" {
  depends_on = [
    aws_iam_role_policy.pipes_pipe_s3_object_created_comprehend
  ]
  name     = aws_sfn_state_machine.s3_object_created_comprehend.name
  role_arn = aws_iam_role.pipes_pipe_s3_object_created_comprehend.arn
  source   = aws_sqs_queue.s3_object_created_comprehend.arn
  target   = aws_sfn_state_machine.s3_object_created_comprehend.arn
  target_parameters {
    step_function_state_machine_parameters {
      invocation_type = "FIRE_AND_FORGET"
    }
  }
}

resource "aws_pipes_pipe" "sfn_state_machine_s3_object_created_text" {
  depends_on = [
    aws_iam_role_policy.pipes_pipe_s3_object_created_text
  ]
  name     = aws_sfn_state_machine.s3_object_created_text.name
  role_arn = aws_iam_role.pipes_pipe_s3_object_created_text.arn
  source   = aws_sqs_queue.s3_object_created_text.arn
  target   = aws_sfn_state_machine.s3_object_created_text.arn
  target_parameters {
    step_function_state_machine_parameters {
      invocation_type = "FIRE_AND_FORGET"
    }
  }
}
