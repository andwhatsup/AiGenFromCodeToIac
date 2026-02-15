output "s3_artifacts_bucket_name" {
  description = "S3 bucket for artifacts (images/results)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine."
  value       = aws_sfn_state_machine.rekognition.arn
}
