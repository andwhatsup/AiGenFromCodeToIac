# Generated Terraform (baseline)

This repository is a **Nebari plugin** that deploys Metrics Server into an existing Kubernetes cluster using Nebari's Terraform/Helm pipeline.

Because the plugin itself does not define standalone AWS runtime infrastructure (it is meant to be consumed by Nebari), this Terraform is a **minimal AWS baseline** that validates and can be used for CI/CD artifacts:

- S3 bucket for artifacts
- Minimal IAM role + inline policy for accessing that bucket

You can extend this to include EKS/Helm if you have a target cluster and want to manage it directly.
