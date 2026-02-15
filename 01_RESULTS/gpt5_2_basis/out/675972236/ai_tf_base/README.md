# Terraform: rigitbot (minimal)

This repository contains a Rust AWS Lambda (using `lambda_runtime`) that responds to **Lambda Function URL** events.

This Terraform deploys:
- IAM role for Lambda execution (+ AWS managed basic logging policy)
- Lambda function (custom runtime `provided.al2`)
- Lambda Function URL (public)

## Packaging

Terraform does **not** build the Rust binary. Provide a zip at `./lambda.zip` (relative to this Terraform folder).

Typical build steps (example):

```bash
cargo build --release --target x86_64-unknown-linux-musl
cp target/x86_64-unknown-linux-musl/release/rigitbot bootstrap
zip -j lambda.zip bootstrap
```

Then:

```bash
terraform init
terraform apply
```
