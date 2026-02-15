provider "kubernetes" {
  config_path = "kubeconfig.yaml"
}

resource "kubernetes_deployment" "python_webapp" {
  metadata {
    name = "python-webapp"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "python-webapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "python-webapp"
        }
      }

      spec {
        container {
          image = var.docker_image
          name  = "python-webapp"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "python_webapp" {
  metadata {
    name = "python-webapp"
  }

  spec {
    selector = {
      app = "python-webapp"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
