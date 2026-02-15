# Terraform (generated)

This Terraform configuration deploys the minimal AWS infrastructure inferred from the repository:

- EventBridge scheduled rule triggers `check_announcement` Lambda
- DynamoDB table stores processed announcement URLs (with TTL) and emits a stream
- DynamoDB stream triggers `send_notification` Lambda
- `send_notification` publishes to an SNS topic
- SNS topic triggers `send_telegram_notification` Lambda
- SSM Parameter Store holds Telegram auth token and per-announcement chat/channel settings

## Notes

- Lambda deployment packages are referenced as local zip files under `artifacts/`.
  They are created as tiny placeholder zips so `terraform init`/`validate` succeed.
  Replace them with real build artifacts in CI/CD.

## Required variables

- `schedule_expression`
- `telegram_auth_token`
- `announcements`

See the upstream repo's `deploy/terraform.tfvars.example` for an example.
