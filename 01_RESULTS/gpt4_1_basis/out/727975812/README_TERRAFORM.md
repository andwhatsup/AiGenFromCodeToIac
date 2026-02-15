# Terraform AWS Infrastructure for Venmo Action Automation

This Terraform configuration deploys:
- An AWS Lambda function (Python) for Venmo automation
- IAM role and permissions for Lambda
- CloudWatch EventBridge rules for scheduling

## Usage
1. Fill in the `locals { venmo_schedules = [...] }` block in `main.tf` with your schedule objects as described in the main project README.
2. Provide your Venmo API token via the `venmo_auth_token` variable (e.g., using a `terraform.tfvars` file or environment variable).
3. Run `terraform init` and `terraform apply`.
