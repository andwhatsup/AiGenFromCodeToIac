# Terraform AWS Infrastructure for cann

This configuration deploys the minimal AWS infrastructure for the serverless application:
- DynamoDB table for announcements
- SNS topic for notifications
- SSM Parameter for Telegram auth token
- Three Lambda functions (check_announcement, send_notification, send_telegram_notification)
- CloudWatch Event Rule for scheduled Lambda trigger

## Usage

1. Set your AWS credentials and region.
2. Set the required variables (see `variables.tf`).
3. Run `terraform init` and `terraform validate` in this directory.
