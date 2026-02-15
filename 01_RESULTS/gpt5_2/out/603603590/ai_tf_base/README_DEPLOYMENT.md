# Terraform deployment (minimal)

This repository contains a `docker-compose.yml` that runs:
- Zookeeper
- Kafka broker
- Kafka UI
- Nginx Proxy Manager

The simplest AWS target is a single EC2 instance in the default VPC, with Docker + docker-compose installed via `user_data`.

## Inputs
- `aws_region`
- `instance_type`
- `ssh_public_key` or `ssh_public_key_path`

## Outputs
- `public_ip`
- `kafka_ui_url`
- `nginx_proxy_manager_url`

## Notes
- Security group opens ports 22, 80, 81, 443, 8080, 9093 to the internet.
- For production, restrict CIDRs and consider managed MSK instead of self-hosted Kafka.
