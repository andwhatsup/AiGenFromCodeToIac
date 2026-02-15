# Terraform (minimal) for this repository

This repository contains a React app (Create React App) with a Dockerfile and a Kubernetes manifest (`deployment-service.yml`) intended to be deployed to **Amazon EKS**.

This Terraform creates a minimal EKS cluster + managed node group in a small VPC with two public subnets.

## Usage

```bash
cd workspace/741591431/ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```

After apply, configure kubectl:

```bash
aws eks --region us-west-1 update-kubeconfig --name EKS_cluster_codewithmuh
kubectl apply -f ../deployment-service.yml
```
