# Generated Terraform

This Terraform is inferred from the repository contents.

The repo is a DevOps challenge focused on:
- Building a Docker image for an Energi node
- Running it on Kubernetes (StatefulSet)
- CI pipeline
- An explicit Terraform task to create IAM entities (role/policy/group/user)

To keep the infrastructure minimal and deterministic (and likely to validate in most environments), this configuration implements the IAM portion (challenge 6):
- IAM role with **no permissions** and an assume-role trust policy for the same AWS account
- IAM policy allowing `sts:AssumeRole` on that role
- IAM group with the policy attached
- IAM user in that group

Apply with:

```bash
terraform init
terraform apply
```
