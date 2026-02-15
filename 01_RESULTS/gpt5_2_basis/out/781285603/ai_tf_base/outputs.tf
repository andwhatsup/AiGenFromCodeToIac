output "iam_role_name" {
  description = "Name of the IAM role that can be assumed by same-account principals."
  value       = aws_iam_role.assumable.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role."
  value       = aws_iam_role.assumable.arn
}

output "iam_policy_arn" {
  description = "ARN of the policy that allows sts:AssumeRole on the role."
  value       = aws_iam_policy.assume_role.arn
}

output "iam_group_name" {
  description = "Name of the IAM group with the assume-role policy attached."
  value       = aws_iam_group.group.name
}

output "iam_user_name" {
  description = "Name of the IAM user in the group."
  value       = aws_iam_user.user.name
}
