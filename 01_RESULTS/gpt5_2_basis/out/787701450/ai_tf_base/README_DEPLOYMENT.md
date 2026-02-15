# Terraform deployment (generated)

This Terraform config provisions the minimal AWS infrastructure inferred from the repository:

- S3 bucket for `text/`, `comprehend/`, and `datalake/` prefixes
- Two SQS queues for S3 object-created notifications
- Two Step Functions state machines (ASL definitions sourced from `../state_machine/*.json`)
- EventBridge Pipes to connect each SQS queue to its corresponding state machine

## Apply

```bash
cd ai_basis_tf
terraform init
terraform apply
```

## Use

Upload a text file to `s3://<bucket>/text/<file>.txt`.
The pipeline will write a JSON result to `s3://<bucket>/comprehend/<etag>.json` and then partitioned records under `s3://<bucket>/datalake/...`.
