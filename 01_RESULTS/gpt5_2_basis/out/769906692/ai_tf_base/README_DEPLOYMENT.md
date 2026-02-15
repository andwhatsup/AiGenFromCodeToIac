# Terraform (AWS) deployment

This Terraform config deploys a minimal AWS setup to run the Node.js HTTP app as a container on **ECS Fargate** behind an **Application Load Balancer**.

## What it creates
- Uses the **default VPC** and its subnets
- ECS Cluster + Fargate Service
- ALB + Target Group + Listener (HTTP/80)
- Security Group allowing inbound HTTP/80
- CloudWatch Log Group
- IAM task execution role (managed policy attachment)

## Usage
```bash
cd workspace/769906692/ai_basis_tf
terraform init
terraform validate
terraform apply
```

After apply, open the `alb_dns_name` output in a browser.

## Notes
- `container_image` defaults to a public Node image to keep the infrastructure minimal.
- To run your own built image, push it to ECR (or another registry) and set `-var container_image=...`.
