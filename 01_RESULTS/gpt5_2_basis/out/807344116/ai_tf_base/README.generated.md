# Generated Terraform (baseline)

This repository demonstrates **Amazon EKS Pod Identity cross-account role assumption**.

The minimal AWS infrastructure generated here is intentionally conservative and should validate in most environments:

- An S3 bucket for artifacts/configs
- An IAM role intended to be used as the **source** role for an EKS Pod Identity association (`pods.eks.amazonaws.com` trust)
- A minimal inline policy allowing `s3:ListAllMyBuckets` (to support the included `example.py`)

What is *not* created:

- EKS cluster / Pod Identity association (requires more context: VPC, subnets, cluster, OIDC, etc.)
- Cross-account destination role (must be created in the destination account)

You can use the output `pod_identity_source_role_arn` as the role to associate with your Kubernetes ServiceAccount via EKS Pod Identity.
