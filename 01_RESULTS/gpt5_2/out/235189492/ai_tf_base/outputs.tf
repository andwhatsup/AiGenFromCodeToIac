output "iterator_lambda_name" {
  description = "Name of the iterator Lambda created by this stack."
  value       = aws_lambda_function.iterator.function_name
}

output "iterator_lambda_arn" {
  description = "ARN of the iterator Lambda created by this stack."
  value       = aws_lambda_function.iterator.arn
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine that performs the high-frequency invocations."
  value       = aws_sfn_state_machine.iterator.arn
}
