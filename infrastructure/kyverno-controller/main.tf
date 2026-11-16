resource "helm_release" "kyverno" {
  count      = var.enabled ? 1 : 0
  name       = "kyverno"
  chart      = "kyverno"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = module.namespace.name
  lint       = true
  atomic     = true
  wait       = true

  set = [{
    name  = "admissionController.replicas"
    value = var.admissioncontroller_replicas
    },
    {
      name  = "backgroundController.replicas"
      value = var.backgroundcontroller_replicas
    },
    {
      name  = "cleanupController.replicas"
      value = var.cleanupcontroller_replicas
    },
    {
      name  = "reportsController.replicas"
      value = var.reportscontroller_replicas
    },
    # Metrics Annotations for Prometheus (local clusters without ServiceMonitor)
    {
      name  = "admissionController.metricsService.annotations.prometheus\\.io/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "backgroundController.metricsService.annotations.prometheus\\.io/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "cleanupController.metricsService.annotations.prometheus\\.io/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "reportsController.metricsService.annotations.prometheus\\.io/scrape"
      value = "true"
      type  = "string"
    },
    # Metrics Annotations for Prometheus (remote clusters (adesso) without ServiceMonitor)
    {
      name  = "reportsController.metricsService.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "cleanupController.metricsService.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "backgroundController.metricsService.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "admissionController.metricsService.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    }
  ]

  set_list = [{
    name  = "existingImagePullSecrets"
    value = [for k, v in module.pull_secrets : v.metadata.name]
    }
  ]
}

# The release had no count before
moved {
  from = helm_release.kyverno
  to   = helm_release.kyverno[0]
}
