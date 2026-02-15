# Generated Terraform (minimal)

This Terraform deploys a minimal EC2-based Node/Express app listening on port 3000, matching the repository's `server.js`.

## Inputs
- `aws_region` (default `us-west-2`)
- `app_name` (default `terraform-deployment-app`)
- `instance_type` (default `t3.micro`)
- `ssh_key_name` (optional) and `allowed_ssh_cidr` (only used if `ssh_key_name` is set)

## Outputs
- `public_ip`
- `app_url` (http://<public-ip>:3000)
