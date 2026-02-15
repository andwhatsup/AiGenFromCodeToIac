This Terraform creates a minimal AWS baseline for the repository:

- An S3 bucket for artifacts (private, versioned, encrypted).

The application code in this repo is a small Flask API (app.py). There is no Dockerfile or deployment manifest in the repository, so the simplest safe infrastructure is provided.

To deploy the Flask app to AWS, you would typically add one of:
- Dockerfile + ECS Fargate + ALB
- Lambda (via container image or zip) + API Gateway

Once such packaging/deployment config exists, the Terraform can be extended accordingly.
