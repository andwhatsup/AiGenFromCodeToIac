output "site_bucket_name" {
  description = "S3 bucket name hosting the MkDocs static website."
  value       = aws_s3_bucket.site.bucket
}

output "site_website_endpoint" {
  description = "S3 static website endpoint (HTTP)."
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for CI/CD artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions deployments (OIDC)."
  value       = aws_iam_role.github_actions_deploy.arn
}
