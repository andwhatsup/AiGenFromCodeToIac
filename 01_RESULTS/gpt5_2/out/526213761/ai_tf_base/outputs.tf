output "s3_bucket_name" {
  description = "S3 bucket that can be used by Kafka Connect S3 sink connector."
  value       = aws_s3_bucket.data.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.data.arn
}

output "ecs_task_role_arn" {
  description = "IAM role ARN suitable for ECS tasks to access the S3 bucket."
  value       = aws_iam_role.ecs_task_role.arn
}
