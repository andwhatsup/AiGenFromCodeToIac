output "python_webapp_service" {
  value = kubernetes_service.python_webapp.status.0.load_balancer.0.ingress
}
