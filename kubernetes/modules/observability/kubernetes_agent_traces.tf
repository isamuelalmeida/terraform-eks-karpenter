#-----------------------------------------
# DEPLOYMENT
#-----------------------------------------

resource "kubernetes_deployment" "agent_traces" {

  metadata {
    name      = var.agent.traces.name
    namespace = var.agent.traces.namespace
  }

  spec {
    selector {
      match_labels = {
        name = var.agent.traces.name
      }
    }

    min_ready_seconds      = 10
    replicas               = 3
    revision_history_limit = 10

    template {
      metadata {
        labels = {
          name = var.agent.traces.name
        }
      }

      spec {
        container {

          image             = "grafana/agent:v0.31.2"
          name              = var.agent.traces.name
          image_pull_policy = "IfNotPresent"

          args = [
            "-config.file=/etc/agent/agent.yaml",
            "-server.http.address=0.0.0.0:80"
          ]

          command = ["/bin/agent"]

          port {
            name           = "http-metrics"
            container_port = 80
          }
          port {
            name           = "otlp"
            container_port = 4317
          }

          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            mount_path = "/etc/agent"
            name       = var.agent.traces.name
          }

        }

        volume {
          name = var.agent.traces.name
          config_map {
            name = var.agent.traces.name
          }
        }

      }
    }
  }

  depends_on = [kubernetes_config_map.agent_traces]

}


#-------------------------------------------------
# SERVICE
#-------------------------------------------------

resource "kubernetes_service" "agent_traces" {

  metadata {
    name      = var.agent.traces.name
    namespace = var.agent.traces.namespace
  }
  spec {
    selector = {
      name = var.agent.traces.name
    }

    port {
      name        = "agent-traces-http-metrics"
      port        = 80
      target_port = 80
    }
    port {
      name        = "agent-traces-otlp"
      port        = 4317
      target_port = 4317
    }

  }

  depends_on = [kubernetes_deployment.agent_traces]

}


#-------------------------------------------------
# CONFIG MAP
#-------------------------------------------------

resource "kubernetes_config_map" "agent_traces" {

  metadata {
    name      = var.agent.traces.name
    namespace = var.agent.traces.namespace
  }

  data = {
    "agent.yaml" = <<-EOT
          server:
            log_level: info
          integrations:
            agent:
              enabled: true
          metrics:
            global:
              scrape_interval: 30s
              remote_write:
              - url: http://mimir-nginx.mimir/api/v1/push
                remote_timeout: 30s
            configs:
            - name: default
              scrape_configs:
                - job_name: agent-traces
                  static_configs:
                    - targets: ['127.0.0.1:8080']
          traces:
            configs:
            - name: default
              batch:
                send_batch_size: 8000
                send_batch_max_size: 0
                timeout: 1s
              receivers:
                otlp:
                  protocols:
                    grpc:
              remote_write:
                - endpoint: tempo-distributor.grafana:4317
                  insecure: true                
                  retry_on_failure:
                    enabled: true
                    max_elapsed_time: 60s
                  sending_queue:
                    num_consumers: 100
                    queue_size: 50000
      EOT
  }

}