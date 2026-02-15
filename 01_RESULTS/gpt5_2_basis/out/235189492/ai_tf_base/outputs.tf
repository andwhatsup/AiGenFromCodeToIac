output "iterator_lambda_arn" {
  description = "ARN of the iterator Lambda that invokes the target Lambda."
  value       = aws_lambda_function.iterator.arn
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine that runs the high-frequency loop."
  value       = aws_sfn_state_machine.hfl.arn
}

output "invocation_count" {
  description = "How many times the target lambda will be invoked per execution."
  value       = local.invocation_count
}
