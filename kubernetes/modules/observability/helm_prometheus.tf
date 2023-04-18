resource "helm_release" "prometheus" {
  atomic = true

  repository = "https://prometheus-community.github.io/helm-charts"

  name    = "prometheus"
  chart   = "kube-prometheus-stack"
  version = "36.0.3"

  namespace        = "prometheus"
  create_namespace = true

  values = [<<-EOT
    defaultRules:
      create: false

    global:
      ingress:
        enabled: false

    alertmanager:
      enabled: false

    grafana:
      enabled: false

    ## Deploy a Prometheus instance
    ##
    prometheus:
      # serviceAccount:
      #   annotations:
      #     eks.amazonaws.com/role-arn: arn:aws:iam::968644489163:role/RoleAdministratorAccess
      server:
        persistentVolume:
          enabled: true
      prometheusSpec:
        nodeSelector:
          nodeTypeClass: observability
        resources:
          requests:
            cpu: 500m
            memory: 500Mi
          limits:
            cpu: 1000m
            memory: 2048Mi
        remoteWrite:
          - headers:
            url: http://mimir-nginx.mimir/api/v1/push
        retention: 2h
        retentionSize: 4GB
        disableCompaction: true
        enableFeatures:
        - memory-snapshot-on-shutdown
        storage:
          volumeClaimTemplate:
            spec:
              resources:
                requests:
                  storage: 4Gi
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 4Gi
        externalLabels:
          cluster: k8s-sam-${var.environment}
        additionalScrapeConfigs:
          - job_name: 'kubernetes-pods'
            kubernetes_sd_configs:
            - role: pod
            relabel_configs:
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
              action: replace
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $1:$2
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_pod_name]
              action: replace
              target_label: kubernetes_pod_name
    EOT
  ]
}