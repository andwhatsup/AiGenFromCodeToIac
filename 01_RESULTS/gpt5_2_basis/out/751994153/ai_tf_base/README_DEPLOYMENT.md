# Terraform deployment (minimal)

This repository contains a static portfolio website served by Nginx in a Docker container.
The minimal AWS deployment inferred from the repo is:

- 1x EC2 instance (Amazon Linux 2023)
- Security group allowing HTTP/HTTPS and optional SSH
- User data installs Docker and runs the configured container image

## Inputs

- `container_image` (default `nginx:latest`): set this to your built image, e.g. GitLab Container Registry image.
- `ssh_ingress_cidr`: restrict SSH to your IP.
- `key_name`: optional existing EC2 key pair name.

## Usage

```bash
cd ai_basis_tf
terraform init
terraform apply -auto-approve \
  -var='container_image=registry.gitlab.com/<group>/<project>/<image>:main' \
  -var='ssh_ingress_cidr=<your_ip>/32' \
  -var='key_name=<your_keypair>'
```

Then open `http://<public_ip>`.
