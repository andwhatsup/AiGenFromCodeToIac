# Terraform baseline for dash-dashboard-demo

This repository describes deploying the Dash app via Elastic Beanstalk (EB) + EB CLI.
To keep the Terraform minimal and broadly compatible (including LocalStack-style environments),
this Terraform creates only foundational AWS resources that EB commonly needs:

- An S3 bucket for application artifacts (zip bundles / EB application versions)
- An IAM role with least-privilege access to that bucket (attach to EC2/EB instances as needed)

Elastic Beanstalk application/environment creation is intentionally not included here because
it often requires additional platform-specific settings and may not be supported in all
validation environments.

## Usage

```bash
terraform init
terraform apply
```

Then use the outputs as inputs to your EB workflow.
