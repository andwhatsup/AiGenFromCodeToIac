# Terraform (minimal) for ssh-key-agent

This repository contains a small Go program that periodically fetches an auth map from a URI (`SKA_KEY_URI`) and writes an `authorized_keys` file.

There is no network service to expose, so this Terraform creates a minimal AWS baseline:

- An S3 bucket to store artifacts/config (e.g., an `authmap` JSON file)
- A reusable IAM policy granting read-only access to that bucket

You can later attach the IAM policy to an EC2 instance profile or an ECS task role if you decide to run the container/binary on AWS compute.

## Usage

```bash
terraform init
terraform validate
terraform apply
```
