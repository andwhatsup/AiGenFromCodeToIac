resource "helm_release" "cert-manager" {
  depends_on       = [kind_cluster.k8s]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.11"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true

  }
}

resource "helm_release" "flink-operator" {
  depends_on       = [helm_release.cert-manager]
  name             = "flink-operator"
  repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.5.0/"
  chart            = "flink-kubernetes-operator"
  namespace        = "flink-operator"
  create_namespace = true
}

resource "helm_release" "ingress_nginx" {
  depends_on       = [kind_cluster.k8s]
  name             = "ingress-nginx"
  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  values           = [file("helm/nginx_ingress_values.yaml")]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
    environment = {
      KUBECONFIG = pathexpand("~/.kube/config")
    }
  }
  depends_on = [helm_release.ingress_nginx]
}
