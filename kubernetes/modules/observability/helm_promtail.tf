resource "helm_release" "promtail" {
  depends_on = [helm_release.loki]

  atomic = true

  repository = "https://grafana.github.io/helm-charts"

  name    = "promtail"
  chart   = "promtail"
  version = "6.5.0"

  namespace = "grafana"

  values = [<<-EOT
      config:
        clients:
          - url: http://loki-distributor.grafana:3100/loki/api/v1/push
            external_labels:
              cluster: k8s-sam-${var.environment}
        snippets:
          pipelineStages:
            - docker: {}
            - multiline:
                # Identify zero-width space as first line of a multiline block.
                # Note the string should be in single quotes.
                firstline: '\x{200B}'
                max_wait_time: 3s
    EOT
  ]
}