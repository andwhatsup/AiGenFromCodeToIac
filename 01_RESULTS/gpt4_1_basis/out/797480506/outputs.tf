output "artifact_bucket_name" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "rekognition_state_machine_arn" {
  value = aws_sfn_state_machine.rekognition_state_machine.arn
}
