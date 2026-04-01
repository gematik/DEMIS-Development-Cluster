resource "helm_release" "policy_reporter" {
  name       = "policy-reporter"
  chart      = "policy-reporter"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set = [{
    name  = "ui.enabled"
    value = true
    },
    {
      name  = "plugin.kyverno.enabled"
      value = true
    },
    {
      name  = "metrics.enabled"
      value = true
    },
    {
      name  = "periodicSync.enabled"
      value = true
    },
    # Metrics Annotations for Prometheus (local clusters without ServiceMonitor)
    {
      name  = "service.annotations.prometheus\\.io/scrape"
      type  = "string"
      value = "true"
    },
    # Metrics Annotations for Prometheus (remote clusters (adesso) without ServiceMonitor)
    {
      name  = "service.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "service.annotations.prometheus\\.io/port"
      type  = "string"
      value = "8080"
    },
    {
      name  = "service.annotations.prometheus\\.io/path"
      type  = "string"
      value = "/metrics"
    }
  ]
}
