# Terraform (minimal) - ECS Fargate task to connect to MongoDB Atlas

This repo contains a Java app that reads `MONGODB_URI` and prints a document from `sample_mflix.movies`.

This Terraform creates:
- CloudWatch Log Group
- ECS Cluster
- ECS Task Definition (Fargate)
- ECS Service (Fargate)

## Required inputs
Provide these via `terraform.tfvars`:

```hcl
container_image    = "123456789.dkr.ecr.eu-west-2.amazonaws.com/mongodb-aws-ecs:latest"
mongodb_uri        = "mongodb+srv://cluster0.abcde.mongodb.net/?authMechanism=MONGODB-AWS"
subnets            = ["subnet-...", "subnet-..."]
security_groups    = ["sg-..."]
execution_role_arn = "arn:aws:iam::123456789:role/ecsTaskExecutionRole"
```

Notes:
- Use public subnets (and `assign_public_ip=true`) if you don't have NAT.
- The execution role must allow ECR pull + CloudWatch logs.
