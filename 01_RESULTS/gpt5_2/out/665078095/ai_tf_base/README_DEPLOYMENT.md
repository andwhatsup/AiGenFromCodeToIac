# Terraform deployment (minimal)

This repository is an Atlas migrations template. The minimal AWS infrastructure to run it is a MySQL database.

This Terraform creates:
- Uses the **default VPC** and its subnets
- Security group allowing MySQL (3306) from `allowed_cidr_blocks`
- An **RDS MySQL** instance

## Usage

```bash
cd workspace/665078095/ai_basis_tf
terraform init
terraform apply \
  -var='db_password=ChangeMe123!'
```

Then you can run Atlas against the created endpoint:

```bash
atlas migrate apply \
  --env local \
  -u "mysql://appuser:ChangeMe123!@$(terraform output -raw db_address):3306/app"
```

Tighten `allowed_cidr_blocks` for real usage.
