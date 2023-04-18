resource "helm_release" "metrics_server" {
  atomic = true

  repository = "https://kubernetes-sigs.github.io/metrics-server"

  name    = "metrics-server"
  chart   = "metrics-server"
  version = "3.8.2"

  namespace = "kube-system"

  set {
    name  = "apiService.create"
    value = "true"
  }

}