output "iterator_lambda_function_name" {
  value = aws_lambda_function.iterator_lambda.function_name
}

output "step_function_arn" {
  value = aws_sfn_state_machine.iterator_step_function.arn
}
