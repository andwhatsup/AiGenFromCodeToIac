terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "minecraft" {
  name         = "itzg/minecraft-server"
  keep_locally = false
}

# resource "docker_image" "proxy" {
#     name = ""
#     keep_locally = false
# }

resource "docker_container" "lobby" {
  image = docker_image.minecraft.image_id
  name  = "lobby"
  ports {
    internal = 25650
    external = 25660
  }
}