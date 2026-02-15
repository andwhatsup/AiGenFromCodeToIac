# Terraform (minimal baseline)

This repository contains a FastAPI app that talks to **HashiCorp Vault** (via `VAULT_ADDR` and `VAULT_TOKEN`).
The upstream repo also includes a separate `tf/` folder that appears to provision Vault.

This Terraform in `ai_basis_tf/` intentionally stays minimal and deployable:
- Creates an S3 bucket for artifacts/static assets.

To deploy the application itself you would typically add:
- ECS Fargate service for the FastAPI container
- A Vault deployment (or use an existing Vault)

## Usage

```bash
cd ai_basis_tf
terraform init
terraform apply
```
