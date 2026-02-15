# Generated Terraform (minimal)

This Terraform deploys the minimal AWS infrastructure inferred from the repository:

- EventBridge schedule -> `check_announcement` Lambda
- DynamoDB table (with stream) to store processed announcement URLs
- DynamoDB stream -> `send_notification` Lambda
- SNS topic -> `send_telegram_notification` Lambda
- SSM Parameter Store for Telegram auth token and per-announcement chat/channel

Note: Lambda code is packaged as placeholder ZIPs so `terraform init`/`validate` succeed.
Replace the placeholder artifacts with real compiled Go Lambda binaries (custom runtime `provided.al2` with `bootstrap`).
