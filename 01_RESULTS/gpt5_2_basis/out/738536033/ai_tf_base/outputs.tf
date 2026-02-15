output "artifacts_bucket_name" {
  description = "S3 bucket for application artifacts (e.g., Elastic Beanstalk source bundles)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "eb_ec2_instance_profile_name" {
  description = "IAM instance profile name that can be used by Elastic Beanstalk EC2 instances."
  value       = aws_iam_instance_profile.eb_ec2.name
}

output "eb_ec2_role_name" {
  description = "IAM role name for Elastic Beanstalk EC2 instances."
  value       = aws_iam_role.eb_ec2_role.name
}
