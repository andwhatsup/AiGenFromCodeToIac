# Terraform (minimal baseline)

This repository contains a FastAPI app that talks to HashiCorp Vault (Transit + Transform engines) via `VAULT_ADDR` and `VAULT_TOKEN`.

The original repo references a `tf/` folder for provisioning Vault, but that folder is not present here. To keep this Terraform minimal and reliably valid, this configuration provisions only baseline AWS resources:

- An S3 bucket for artifacts/static assets
- An IAM role + inline policy stub that could be used by ECS tasks or Lambda later

## Next steps (not implemented here)

If you want to run the FastAPI app on AWS, a typical minimal target would be:

- ECR repository for the container image
- ECS Fargate service (public IP) behind an ALB
- Secrets Manager / SSM for `VAULT_ADDR` and a Vault token (or better: IAM auth to Vault)

Those are intentionally omitted to keep the configuration minimal and deterministic.
