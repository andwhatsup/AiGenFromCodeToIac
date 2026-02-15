# Terraform deployment (minimal)

This Terraform creates a minimal EC2 instance in the default VPC with a security group allowing 80/443 (and 22 from `ssh_ingress_cidr`).

It installs Docker and runs a stock `nginx:latest` container.

To use your own site image, replace the `docker run ... nginx:latest` line in `main.tf` with a pull/run of your built image (ECR/GitLab registry) or bake the site into the instance.
