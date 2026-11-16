locals {
  # The namespace is needed for the monitoring stack (local only), the Audit Log Service or if Kiali/Jaeger are moved
  namespace_created = local.grafana_enabled || local.prometheus_enabled || local.kiali_jaeger_in_namespace || local.audit_log_service_enabled
  # Own namespace or the fallback (istio-system)
  namespace = local.namespace_created ? module.namespace[0].name : var.fallback_namespace
  # Kiali and Jaeger stay in the fallback namespace unless explicitly moved
  kiali_jaeger_namespace = local.kiali_jaeger_in_namespace ? local.namespace : var.fallback_namespace
}

module "metadata" {
  source = "../modules/metadata"
  count  = local.namespace_created ? 1 : 0

  cluster     = local.stage_name
  region      = local.cluster_region
  application = "observability"
  component   = "monitoring"
}

module "namespace" {
  source = "../modules/namespace"
  count  = local.namespace_created ? 1 : 0

  name                   = var.namespace
  labels                 = module.metadata[0].tags
  enable_istio_injection = true
}
