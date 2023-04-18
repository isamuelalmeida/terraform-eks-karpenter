resource "helm_release" "tempo" {
  depends_on = [helm_release.grafana]

  atomic = true

  repository = "https://grafana.github.io/helm-charts"

  name    = "tempo"
  chart   = "tempo-distributed"
  version = "0.27.8"

  namespace = "grafana"

  timeout = 600

  values = [<<-EOT
    fullnameOverride: tempo

    tempo:
      structuredConfig:
        query_frontend:
          max_retries: 5
          query_shards: 20
          search:
            max_duration: 1h  # Range máximo de tempo para pesquisar por traces
            concurrent_jobs: 2000
        querier:
          query_timeout: 300s
          max_concurrent_queries: 20
          search:
            query_timeout: 300s
        storage:
          trace:
            cache_max_block_age: 24h
            search:
              cache_control:
                footer: true
                column_index: true
                offset_index: true
            pool:
              max_workers: 100

    server:
      httpListenPort: 3100
      logLevel: info
      logFormat: logfmt
      grpc_server_max_recv_msg_size: 9437184
      grpc_server_max_send_msg_size: 9437184


    global_overrides:
      per_tenant_override_config: /conf/overrides.yaml
      ingestion_burst_size_bytes: 60000000
      ingestion_rate_limit_bytes: 50000000
      max_bytes_per_trace: 10000000
      max_search_bytes_per_trace: 0
      max_bytes_per_tag_values_query: 10000000
      metrics_generator_processors:
        - service-graphs
        - span-metrics

    overrides: |
      overrides: {}

    metricsGenerator:
      enabled: true
      replicas: 2
      config:
        registry:
          collection_interval: 30s
          stale_duration: 5m
          external_labels:
            cluster: k8s-sam-${var.environment}
        processor:
          service_graphs:
            max_items: 5000
            wait: 10s
            workers: 10
          span_metrics:
            dimensions: ['http.host','http.method','http.url','http.target','http.status_code','http.client_ip','http.user_agent']
        storage:
          remote_write_flush_deadline: 1m
          remote_write:
          - headers:
            url: http://mimir-nginx.mimir/api/v1/push
    
    metaMonitoring:
      serviceMonitor:
        enabled: true
        namespaceSelector:
          matchNames:
            - grafana
        labels:
          release: prometheus
        interval: 30s
      grafanaAgent:
        enabled: false
        installOperator: false

    memcached:
      enabled: true
      host: memcached
    
    memcachedExporter:
      enabled: true

    compactor:
      replicas: 2
      config:
        compaction:
          block_retention: 168h   # Tempo de persistência dos dados

    ingester:
      replicas: 2
      config:
        replication_factor: 2
        max_block_bytes: 50000000
        complete_block_timeout: 1m

    distributor:
      replicas: 1    
    
    queryFrontend:      
      replicas: 1

    querier:
      replicas: 2      
      config:
        frontend_worker:
          grpc_client_config: {}
    
    search:
      enabled: true

    minio:
      enabled: false

    traces:
      otlp:
        grpc:
          # -- Enable Tempo to ingest Open Telemetry GRPC traces
          enabled: true

    storage:
      trace:
        backend: s3
        s3:
          bucket: infra-sam-tempo-${var.environment}
          endpoint: s3.dualstack.us-east-1.amazonaws.com
          access_key: ${var.aws_access_key_id}
          secret_key: ${var.aws_secret_access_key}
          region: us-east-1
    EOT
  ]
}