resource "docker_image" "node-img" {
  name          = var.image_name
  keep_locally  = false
  pull_triggers = ["always"]
}

resource "docker_container" "node-app" {
  name  = "node-app-container"
  image = docker_image.node-img.image_id
  ports {
    internal = var.internal_port
    external = var.external_port
  }
}