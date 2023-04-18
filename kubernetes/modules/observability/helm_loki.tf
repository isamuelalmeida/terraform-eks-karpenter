resource "helm_release" "loki" {

  atomic = true

  repository = "https://grafana.github.io/helm-charts"

  name    = "loki"
  chart   = "loki-distributed"
  version = "0.63.0"

  namespace = "grafana"

  values = [<<-EOT
      fullnameOverride: loki

      loki:
        config: |
          auth_enabled: false

          server:
            http_listen_port: 3100
            grpc_server_max_send_msg_size: 102400000
            grpc_server_max_recv_msg_size: 102400000

          distributor:
            ring:
              kvstore:
                store: memberlist

          memberlist:
            join_members:
              - {{ include "loki.fullname" . }}-memberlist

          ingester:
            lifecycler:
              ring:
                kvstore:
                  store: memberlist
                replication_factor: 1
            chunk_idle_period: 1m
            chunk_block_size: 10000000
            chunk_target_size: 10000000
            chunk_encoding: snappy
            chunk_retain_period: 0s
            max_transfer_retries: 0
            wal:
              dir: /var/loki/wal

          querier:
            query_timeout: 5m
            query_ingesters_within: 0
            max_concurrent: 20
            query_store_only: false
            engine:
              timeout: 5m

          limits_config:
            enforce_metric_name: false
            reject_old_samples: true
            reject_old_samples_max_age: 168h
            max_cache_freshness_per_query: 10m
            split_queries_by_interval: 15m
            retention_period: 336h # Retenção de 2 semanas

          {{- if .Values.loki.schemaConfig}}
          schema_config:
          {{- toYaml .Values.loki.schemaConfig | nindent 2}}
          {{- end}}
          {{- if .Values.loki.storageConfig}}
          storage_config:
          {{- if .Values.indexGateway.enabled}}
          {{- $indexGatewayClient := dict "server_address" (printf "dns:///%s:9095" (include "loki.indexGatewayFullname" .)) }}
          {{- $_ := set .Values.loki.storageConfig.boltdb_shipper "index_gateway_client" $indexGatewayClient }}
          {{- end}}
          {{- toYaml .Values.loki.storageConfig | nindent 2}}
          {{- end}}

          frontend_worker:
            frontend_address: {{ include "loki.queryFrontendFullname" . }}:9095

          frontend:
            log_queries_longer_than: 5s
            compress_responses: true
            max_outstanding_per_tenant: 4096
            tail_proxy_url: http://{{ include "loki.querierFullname" . }}:3100

          compactor:
            shared_store: s3
            retention_enabled: true

        schemaConfig:
          configs:
          - from: 2021-01-01
            store: boltdb-shipper
            object_store: aws
            schema: v11
            index:
              prefix: loki_index_
              period: 24h

        storageConfig:
          boltdb_shipper:
            shared_store: s3
          aws:
            s3: s3://us-east-1
            bucketnames: ${aws_s3_bucket.infra_sam_loki.bucket}
            access_key_id: ${var.aws_access_key_id}
            secret_access_key: ${var.aws_secret_access_key}

      ingester:
        kind: StatefulSet

      querier:
        replicas: 2

      gateway:
        enabled: true

      compactor:
        enabled: true

      serviceMonitor:
        enabled: true
        labels:
          release: prometheus
        namespaceSelector:
          matchNames:
            - grafana

    EOT
  ]
}