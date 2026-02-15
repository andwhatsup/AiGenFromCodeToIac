# Generated Terraform (minimal)

This repository contains a Fastify + Prisma API that requires a PostgreSQL database (`DATABASE_URL`).

This Terraform creates:
- An RDS PostgreSQL instance in the default VPC/subnets
- A security group allowing inbound 5432 from `allowed_cidr_blocks`
- A small S3 bucket for artifacts (baseline)

## Usage

```bash
cd workspace/781215001/ai_basis_tf
terraform init
terraform apply -var='db_password=CHANGEME'
```

After apply, use the `database_url` output as your `DATABASE_URL`.
