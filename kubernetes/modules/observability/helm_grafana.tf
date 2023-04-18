resource "helm_release" "grafana" {
  depends_on = [module.rds_grafana]

  atomic = true

  repository = "https://grafana.github.io/helm-charts"

  name             = "grafana"
  chart            = "grafana"
  version          = "6.52.9"
  namespace        = "grafana"
  create_namespace = true

  values = [<<-EOT
    service:
      type: NodePort
    plugins:
      - grafana-polystat-panel
      
    adminPassword: ${var.grafana_admin_password}

    grafana.ini:
      database:
        type: postgres
        name: ${var.grafana_database_name}
        host: ${module.rds_grafana.db_instance_address}
        user: ${var.grafana_database_username}
        password: ${var.grafana_database_password}
      server:
        root_url: https://grafana.${var.domain}
      feature_toggles:
        enable: tempoSearch tempoBackendSearch
    EOT
  ]
}