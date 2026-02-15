# Terraform (minimal) for Amazon-FE

This repository appears to be a React frontend (Create React App). The minimal AWS infrastructure to support it is an S3 bucket to store/host the built static assets.

## Deploy steps (out of scope for Terraform)
1. Build: `npm ci && npm run build`
2. Upload `build/` contents to the created S3 bucket.
3. Optionally add CloudFront + OAC for public distribution.
