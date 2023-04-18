resource "helm_release" "mimir" {
  atomic = true

  repository = "https://grafana.github.io/helm-charts"

  name    = "mimir"
  chart   = "mimir-distributed"
  version = "3.3.0"

  namespace        = "mimir"
  create_namespace = true

  values = [<<-EOT

      alertmanager:
        enabled: false

      ruler:
        enabled: false

      minio:
        enabled: false

      overrides_exporter:
        enabled: false

      nginx:
        replicas: 1

      store_gateway:
        replicas: 1
        persistentVolume:
          size: 10Gi

      compactor:
        replicas: 1
        persistentVolume:
          size: 10Gi

      ingester:
        replicas: 2
        persistentVolume:
          size: 20Gi

      distributor:
        replicas: 1

      query_frontend:
        replicas: 1

      query_scheduler:
        enabled: true
        replicas: 1

      querier:
        replicas: 2

      metaMonitoring:
        serviceMonitor:
          enabled: true
          namespaceSelector:
            matchNames:
              - mimir
          labels:
            release: prometheus
          interval: 30s
        grafanaAgent:
          enabled: false
          installOperator: false

      mimir:
        structuredConfig:
          blocks_storage:
            s3:
              bucket_name: ${aws_s3_bucket.infra_sam_mimir.bucket}
              endpoint: s3.dualstack.us-east-1.amazonaws.com
              access_key_id: ${var.aws_access_key_id}
              secret_access_key: ${var.aws_secret_access_key}
              region: us-east-1

    EOT
  ]
}
