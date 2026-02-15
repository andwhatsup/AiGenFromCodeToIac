output "bucket_name" {
  description = "S3 bucket used for input text, comprehend output, and datalake partitions."
  value       = aws_s3_bucket.data.bucket
}

output "text_events_queue_url" {
  value = aws_sqs_queue.text_events.id
}

output "comprehend_events_queue_url" {
  value = aws_sqs_queue.comprehend_events.id
}

output "s3_object_created_text_state_machine_arn" {
  value = aws_sfn_state_machine.s3_object_created_text.arn
}

output "s3_object_created_comprehend_state_machine_arn" {
  value = aws_sfn_state_machine.s3_object_created_comprehend.arn
}

output "pipe_text_arn" {
  value = aws_pipes_pipe.text.arn
}

output "pipe_comprehend_arn" {
  value = aws_pipes_pipe.comprehend.arn
}
