# Terraform (generated)

This Terraform config deploys the minimal AWS infrastructure inferred from the repository:

- An S3 bucket configured for **static website hosting** (MkDocs output)
- A separate S3 bucket for **CI/CD artifacts**
- An IAM role + policy intended for **GitHub Actions OIDC** deployments

## Notes
- Bucket names must be globally unique. Defaults use `${app_name}-${environment}`.
- To actually use the GitHub Actions role, set:
  - `github_oidc_provider_arn` to your IAM OIDC provider ARN for `token.actions.githubusercontent.com`
  - `github_subjects` to the allowed `sub` claim patterns.

Example subjects:

```hcl
github_subjects = [
  "repo:ntno/mkdocs-demo:ref:refs/heads/main"
]
```
