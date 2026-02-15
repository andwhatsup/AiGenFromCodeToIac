# Terraform (minimal) for infrafy

This Terraform creates a minimal PostgreSQL database in AWS RDS, matching the repository's needs (Fastify + Prisma app requires `DATABASE_URL`).

## Usage

```bash
cd workspace/781215001/ai_basis_tf
terraform init
terraform validate
terraform plan -var='db_password=change-me'
```

For dev-only access, the DB is publicly accessible and allows inbound from `allowed_cidr_blocks` (default `0.0.0.0/0`). Restrict this for real usage.
