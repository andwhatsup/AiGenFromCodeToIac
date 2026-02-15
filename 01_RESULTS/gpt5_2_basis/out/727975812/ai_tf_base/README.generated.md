# Generated Terraform (ai_basis_tf)

This Terraform deploys the minimal AWS infrastructure inferred from the repository:

- **AWS Lambda (Python)** running `handler.py` to send Venmo payments/requests.
- **EventBridge (CloudWatch Events) schedule rules** to trigger the Lambda with a JSON payload.
- **IAM role** for Lambda basic logging.
- Optional **SNS topic + CloudWatch alarm** to email on Lambda errors.

## Inputs
- `venmo_auth_token` (required): Venmo API token.
- `venmo_schedules` (optional): list of schedules with `cron_expression` and `payload`.
- `alarm_email` (optional): if set, creates SNS + alarm.

## Example
```hcl
venmo_auth_token = "..."

venmo_schedules = [
  {
    name            = "RentPayment"
    description     = "Monthly rent"
    cron_expression = "cron(0 9 1 * ? *)"
    payload         = jsonencode({
      amount              = 850
      action              = "payment"
      note                = "Rent"
      recipient_user_name = "RecipientVenmoUserName"
    })
  }
]

alarm_email = "me@example.com"
```
