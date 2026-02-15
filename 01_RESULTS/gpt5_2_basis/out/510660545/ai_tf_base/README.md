# ai_basis_tf

This Terraform configuration is a minimal AWS baseline inferred from the repository.

The repository is an Infrastructure-as-Code starter kit (Terraform/Terragrunt) and
does not contain an application workload to deploy (no app source code, no compose,
no runtime service). The `live/*` Terragrunt configuration indicates an S3 backend
and DynamoDB state locking pattern.

This module therefore provisions:
- An S3 bucket (versioned, encrypted, public access blocked) for artifacts/state-like storage
- A DynamoDB table for Terraform state locking

## Usage

```bash
terraform init
terraform validate
terraform plan
```
