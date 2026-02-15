# Generated Terraform (minimal baseline)

This repository contains a Docker image intended to run as a Kubernetes CronJob to back up a Nextcloud instance (mysqldump + rclone to FTP).

Because the repo does not include Kubernetes manifests or a specific AWS runtime target, this Terraform creates a minimal, broadly-applicable AWS baseline:

- **S3 bucket** for artifacts/backups/log exports (private, versioned, SSE-S3).
- **IAM role + policy stub** (assumable by ECS tasks) with read/write access to that bucket.

You can extend this to a full runtime (e.g., ECS Scheduled Task, EKS CronJob, or external Kubernetes) by:
- Building/pushing the Docker image to ECR
- Scheduling the container (EventBridge + ECS task, or Kubernetes CronJob)
- Supplying required env vars (DB_HOST/DB_USER/DB_PASS/FTP_HOST/FTP_USER/FTP_PASS)

## Usage

```bash
cd workspace/725041959/ai_basis_tf
terraform init
terraform validate
terraform plan
```
