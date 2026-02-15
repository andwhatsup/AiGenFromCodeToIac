# Terraform deployment (minimal)

This repository is an Atlas migrations template. The minimal AWS infrastructure to run it is a MySQL database.

This Terraform creates:
- Uses the **default VPC** and its subnets
- Security group allowing inbound MySQL (3306) from `allowed_cidr_blocks`
- RDS MySQL 8.0 instance

## Usage

```bash
cd ai_basis_tf
terraform init
terraform apply
```

After apply, use the outputs to connect and run Atlas migrations, e.g.:

```bash
atlas migrate apply --env local -u "mysql://<user>:<pass>@<endpoint>:3306/app"
```

Adjust `allowed_cidr_blocks` and `publicly_accessible` for safer setups.
