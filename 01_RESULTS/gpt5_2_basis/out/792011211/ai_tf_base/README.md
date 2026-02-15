# Terraform (minimal baseline)

This Terraform configuration is a **minimal, validation-friendly baseline** inferred from the repository.

The application is a Flask web app that needs an OpenWeatherMap API key. The upstream repo describes an EKS-based deployment, but to keep this configuration minimal and likely to work in constrained environments, this Terraform creates:

- An S3 bucket for artifacts/static assets
- An AWS Secrets Manager secret placeholder for the API key (optional)

## Variables

- `aws_region` (default `us-east-1`)
- `api_key_secret_name` (default `/python-weather-app/api-key`)
- `manage_api_key_secret` (default `true`)
- `api_key_secret_string` (default `null`, sensitive)

## Notes

- If you already created the secret manually (as described in the repo README), set `manage_api_key_secret=false`.
- Avoid setting `api_key_secret_string` unless you accept the secret value being managed by Terraform.
