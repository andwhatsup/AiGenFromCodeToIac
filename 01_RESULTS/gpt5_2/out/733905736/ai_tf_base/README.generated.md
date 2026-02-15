# Generated Terraform (minimal)

This repository contains a Dockerfile based on `sonarqube:10.4.1-community`.
A production SonarQube deployment typically requires:
- Compute to run the container (ECS/EC2)
- A PostgreSQL database (RDS)
- Persistent storage for SonarQube data
- Ingress (ALB / reverse proxy)

To keep the Terraform minimal and easy to validate/apply in many environments, this configuration provisions:
- An S3 bucket for artifacts/backups
- An IAM role + policy stub suitable for attaching to an ECS task role later

You can extend this by adding ECS Fargate + ALB + RDS when you are ready.
