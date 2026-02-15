## Terraform: hello-world-nodejs on AWS (minimal)

This Terraform deploys the repository's Node.js "Hello World" container as an ECS Fargate service behind an Application Load Balancer (HTTP).

### What it creates
- Uses the **default VPC** and its subnets
- ECS Cluster + Fargate Service
- ALB + Target Group + Listener (port 80)
- Security groups
- CloudWatch Log Group
- IAM task execution role (managed policy attachment)

### Variables
- `container_image` defaults to `tusharkshahi/hello_world_nodejs:latest`
- `aws_region` defaults to `us-east-1`

### Outputs
- `alb_dns_name` (open in browser)
