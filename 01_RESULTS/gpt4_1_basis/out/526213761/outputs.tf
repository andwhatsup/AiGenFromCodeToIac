output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "flink_job_role_arn" {
  value = aws_iam_role.flink_job_role.arn
}
