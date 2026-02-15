# Terraform deployment (generated)

This Terraform deploys a minimal EC2-based web server (nginx + php-fpm) similar to the repository's intent.

## Inputs
- `allowed_ssh_cidr`: set to your public IP/32 for SSH.
- `allowed_http_cidr`: set to your public IP/32 (or 0.0.0.0/0) for HTTP.
- `key_pair_name`: optional existing EC2 key pair name.

## Run
```bash
terraform init
terraform validate
terraform plan \
  -var='allowed_ssh_cidr=YOUR.IP.ADDR/32' \
  -var='allowed_http_cidr=YOUR.IP.ADDR/32'
terraform apply
```
