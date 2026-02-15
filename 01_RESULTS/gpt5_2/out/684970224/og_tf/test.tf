resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "kube-prometheus"
  version    = "8.17.1"
}
