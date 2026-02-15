# Terraform: ECS Fargate runner for MongoDB Atlas demo

This repo builds a small Java app into a container that connects to MongoDB Atlas using `MONGODB_URI`.

## Inputs
- `container_image` (required): image URI (ECR or Docker Hub)
- `mongodb_uri` (required): MongoDB connection string
- `subnet_ids` (optional): subnets for the service; defaults to default VPC subnets
- `security_group_ids` (optional): security groups for the task ENI

## Example terraform.tfvars
```hcl
aws_region         = "eu-west-2"
container_image    = "123456789.dkr.ecr.eu-west-2.amazonaws.com/mongodb-aws-ecs:latest"
mongodb_uri        = "mongodb+srv://cluster0.abcde.mongodb.net/?authMechanism=MONGODB-AWS"
subnet_ids         = ["subnet-abc", "subnet-def"]
security_group_ids = ["sg-123"]
```

If you need to use an existing execution role:
```hcl
create_task_execution_role = false
execution_role_arn         = "arn:aws:iam::123456789:role/ecsTaskExecutionRole"
```
