variable "github_oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for GitHub Actions (token.actions.githubusercontent.com)."
  type        = string
  default     = ""
}

variable "github_subjects" {
  description = "Allowed GitHub OIDC subject patterns (sub claim). Example: ['repo:org/repo:ref:refs/heads/main']"
  type        = list(string)
  default     = []
}
