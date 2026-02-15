# Terraform: test-kafka (minimal)

This Terraform deploys a **single EC2 instance** in the **default VPC** and uses **user_data** to install Docker and run the repository's `docker-compose.yml` (Zookeeper, Kafka broker, Kafka UI, Nginx Proxy Manager).

## Inputs
- `ssh_public_key` (optional): set to create an EC2 key pair and enable SSH access.
- `allowed_ssh_cidr`, `allowed_ui_cidr`: restrict inbound access.

## Outputs
- `kafka_ui_url`: `http://<public_ip>:8080`
- `kafka_bootstrap`: `<public_ip>:9093`
