locals {
  name_prefix = var.app_name
}

# Minimal baseline infrastructure:
# - S3 bucket for artifacts/static assets
# - Secrets Manager secret placeholder for API key (optional)

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name_prefix}-artifacts-"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-artifacts"
  })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a secret if it doesn't already exist. If you already created it manually,
# you can import it or set manage_api_key_secret=false and use a data source instead.
variable "manage_api_key_secret" {
  description = "Whether Terraform should create/manage the API key secret. Set false if you created it out-of-band."
  type        = bool
  default     = true
}

resource "aws_secretsmanager_secret" "api_key" {
  count = var.manage_api_key_secret ? 1 : 0

  name = var.api_key_secret_name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-api-key"
  })
}

# Optional placeholder secret value. Leave null to avoid storing secrets in state.
variable "api_key_secret_string" {
  description = "Optional secret string to store (JSON). Leave null to avoid writing secret material via Terraform."
  type        = string
  default     = null
  sensitive   = true
}

resource "aws_secretsmanager_secret_version" "api_key" {
  count = var.manage_api_key_secret && var.api_key_secret_string != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.api_key[0].id
  secret_string = var.api_key_secret_string
}

# If not managing the secret, look it up.
data "aws_secretsmanager_secret" "api_key" {
  count = var.manage_api_key_secret ? 0 : 1

  name = var.api_key_secret_name
}
