output "input_bucket" {
  value = aws_s3_bucket.input.bucket
}

output "output_bucket" {
  value = aws_s3_bucket.output.bucket
}

output "comprehend_step_function_arn" {
  value = aws_sfn_state_machine.comprehend.arn
}

output "datalake_step_function_arn" {
  value = aws_sfn_state_machine.datalake.arn
}
