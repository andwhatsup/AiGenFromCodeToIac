provider "aws" {
  region = var.aws_region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
