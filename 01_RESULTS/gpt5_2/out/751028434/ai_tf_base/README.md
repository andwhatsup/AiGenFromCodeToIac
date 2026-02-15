# Terraform - Nebari Metrics Server (minimal)

This Terraform configuration deploys the Kubernetes **metrics-server** via the Helm provider.

## Prerequisites
- A reachable Kubernetes cluster
- `kubectl` configured (kubeconfig at `~/.kube/config` by default)

## Inputs
- `name`, `namespace`: Helm release settings
- `affinity`: passed into chart values
- `overrides`: arbitrary Helm values overrides

## Usage
```bash
terraform init
terraform validate
terraform apply
```
