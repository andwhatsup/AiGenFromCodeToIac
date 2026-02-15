# Generated Terraform (minimal)

This repository builds a small companion daemon (`ssh-key-agent`) that periodically fetches an auth map from `SKA_KEY_URI` and writes an `authorized_keys` file.

## Deployment choice

Minimal AWS deployment is an **ECS Fargate service** running a single task (no load balancer) with public IP, using the **default VPC/subnets**.

## Required variables

- `ska_key_uri` (string)
- `ska_groups` (string)

Optional:
- `container_image` (defaults to `quay.io/utilitywarehouse/ssh-key-agent:latest`)
- `ska_interval` (defaults to 60)
- `ska_akf_loc` (defaults to `/authorized_keys`)

## Example

```bash
terraform init
terraform apply \
  -var 'ska_key_uri=https://example.com/authmap' \
  -var 'ska_groups=group@domain.com,group2@domain.com'
```
