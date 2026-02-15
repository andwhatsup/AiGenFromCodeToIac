provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes = {
    host                   = var.kubernetes_host
    cluster_ca_certificate = base64decode(var.kubernetes_ca_certificate)
    token                  = var.kubernetes_token
  }
}
