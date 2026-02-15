# ai_basis_tf

Minimal Terraform configuration inferred from this repository.

This repo is a Terratest + LocalStack example that provisions AWS resources and validates them via tests.
The tests expect an S3 bucket with:
- versioning enabled
- a bucket policy attached (optional via `with_policy`)
- server access logging enabled to a `-logs` bucket with prefix `TFStateLogs/`

This Terraform is intentionally LocalStack-friendly by default (endpoints, skip validations).
To use real AWS, set `aws_endpoint_url` to an empty string and set real credentials.
