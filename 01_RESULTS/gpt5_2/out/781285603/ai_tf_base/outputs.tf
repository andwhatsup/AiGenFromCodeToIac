output "iam_role_name" {
  description = "Created IAM role name."
  value       = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "Created IAM role ARN."
  value       = aws_iam_role.this.arn
}

output "iam_policy_arn" {
  description = "Created IAM policy ARN."
  value       = aws_iam_policy.this.arn
}

output "iam_group_name" {
  description = "Created IAM group name."
  value       = aws_iam_group.this.name
}

output "iam_user_name" {
  description = "Created IAM user name."
  value       = aws_iam_user.this.name
}
