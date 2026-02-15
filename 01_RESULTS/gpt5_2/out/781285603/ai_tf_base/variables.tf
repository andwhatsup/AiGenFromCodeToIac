variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name used for IAM entities (role, policy, group, user)."
  type        = string
  default     = "devops-challenge"
}

variable "use_suffixes" {
  description = "If true, append -role/-policy/-group/-user suffixes. If false, use the same base name for all entities."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
