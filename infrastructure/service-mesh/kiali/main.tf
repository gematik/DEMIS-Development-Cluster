# Based on Istio Addon - https://github.com/istio/istio/blob/1.17.2/samples/addons/kiali.yaml
locals {
  app           = "kiali"
  version       = var.kiali_version
  image_version = "v${var.kiali_version}"
  port          = 20001
  metrics_port  = 9090
}

# Creates a random Signing Key for Kiali (used to sign the login token)
resource "random_string" "kiali_signing_key" {
  length  = 32
  special = false
}

resource "helm_release" "this" {
  name            = local.app
  repository      = var.kiali_helm_repository
  chart           = "kiali-server"
  namespace       = var.target_namespace
  version         = local.version
  max_history     = 3
  wait            = true
  lint            = true
  atomic          = true
  wait_for_jobs   = true
  cleanup_on_fail = true

  values = [templatefile("${abspath(path.module)}/chart-values.tftpl.yml",
    {
      service_port  = local.port,
      metrics_port  = local.metrics_port
      namespace     = var.target_namespace
      image_version = local.image_version
      signing_key   = random_string.kiali_signing_key.result
      # Cluster-internal Url to Prometheus
      prometheus_url = var.prometheus_service_url
      # Cluster-internal Url to Tracing
      tracing_url = var.tracing_service_url
      # Cluster-internal Url to Grafana
      grafana_url = var.grafana_service_url
      # External (Public) Url to Grafana
      grafana_public_url = var.grafana_public_url
    }
  )]
}