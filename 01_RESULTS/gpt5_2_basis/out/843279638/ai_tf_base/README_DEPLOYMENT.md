# Terraform (minimal) for Counter React App

This repository contains a simple React counter app. The minimal AWS infrastructure to host a static React build is an S3 bucket.

This Terraform creates:
- A private S3 bucket for the site build output
- A private S3 bucket for artifacts

> Note: This does **not** create CloudFront or public website hosting. This is intentionally minimal and conservative.
