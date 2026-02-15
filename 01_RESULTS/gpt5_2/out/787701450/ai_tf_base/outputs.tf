output "bucket_name" {
  description = "S3 bucket used for input and outputs"
  value       = aws_s3_bucket.pipeline.bucket
}

output "text_events_queue_url" {
  description = "SQS queue URL receiving S3 text/ object created events"
  value       = aws_sqs_queue.text_events.id
}

output "comprehend_events_queue_url" {
  description = "SQS queue URL receiving S3 comprehend/ object created events"
  value       = aws_sqs_queue.comprehend_events.id
}

output "sfn_state_machine_text_arn" {
  description = "ARN of the Step Functions state machine for text uploads"
  value       = aws_sfn_state_machine.s3_object_created_text.arn
}

output "sfn_state_machine_comprehend_arn" {
  description = "ARN of the Step Functions state machine for comprehend outputs"
  value       = aws_sfn_state_machine.s3_object_created_comprehend.arn
}
