## Terraform: rigitbot (AWS Lambda)

This repository contains a Rust AWS Lambda handler (see `src/main.rs`) that is compatible with **Lambda Function URLs**.

### What this Terraform deploys
- IAM role for Lambda execution
- Lambda function (expects a pre-built zip)
- Optional Lambda Function URL (public, `authorization_type = NONE`)

### Build artifact expected
This Terraform expects a zip at `../build/rigitbot.zip` relative to this folder.

Example build using cargo-lambda:
```bash
cargo lambda build --release --arm64
mkdir -p build
cargo lambda package --output-format zip --output build/rigitbot.zip
```

Then:
```bash
cd ai_basis_tf
terraform init
terraform apply
```
