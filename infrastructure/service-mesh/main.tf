module "istio" {
  source                          = "./istio"
  chart_version                   = var.istio_version
  local_deployment                = var.local_deployment
  local_node_ports_istio          = var.local_node_ports_istio
  namespace                       = var.namespace
  trace_sampling                  = var.trace_sampling
  replica_count                   = var.istio_replica_count
  external_ip                     = var.external_ip
  ingress_annotations             = var.ingress_annotations
  enable_native_sidecar_injection = coalesce(var.enable_native_sidecar_injection, false)
}

module "kiali" {
  source           = "./kiali"
  kiali_version    = var.kiali_version
  target_namespace = var.namespace
  # Define the Cluster-internal URL for Prometheus
  prometheus_service_url = var.prometheus_enabled ? module.prometheus[0].prometheus_service_url : var.prometheus_service_url
  # Define the Cluster-internal URL for Tracing (Jaeger)
  tracing_service_url = var.jaeger_enabled ? module.jaeger[0].tracing_service_url : var.tracing_service_url
  # Define the Cluster-internal URL for Grafana
  grafana_service_url = var.grafana_enabled ? module.grafana[0].grafana_service_url : var.grafana_service_url
  # Define the Public URL for Grafana (might require Port-Forwarding)
  grafana_public_url = var.grafana_enabled ? module.grafana[0].grafana_public_url : var.grafana_public_url
  # Enable only if explicitly set
  count = var.kiali_enabled ? 1 : 0
  # Add dependency
  depends_on = [module.istio]
}

module "prometheus" {
  source             = "./prometheus"
  prometheus_version = var.prometheus_version
  target_namespace   = var.namespace
  # Enable only if explicitly set
  count = var.prometheus_enabled ? 1 : 0
  # Add dependency
  depends_on = [module.istio]
}

module "jaeger" {
  source                 = "./jaeger"
  jaeger_version         = var.jaeger_version
  jaeger_digest          = var.jaeger_digest
  target_namespace       = var.namespace
  jaeger_max_traces      = coalesce(var.jaeger_max_traces, "50000")
  jaeger_storage_backend = coalesce(var.jaeger_storage_backend, "memory")
  jaeger_ttl_spans       = coalesce(var.jaeger_ttl_spans, "48h")
  # Enable only if explicitly set
  count = var.jaeger_enabled ? 1 : 0
  # Add dependency
  depends_on = [module.istio]
}

module "grafana" {
  source           = "./grafana"
  grafana_version  = var.grafana_version
  grafana_digest   = var.grafana_digest
  target_namespace = var.namespace
  # Enable only if explicitly set
  count = var.grafana_enabled ? 1 : 0
  # Used for downloading the Dashboards
  istio_version = var.istio_version
  # Add dependency
  depends_on = [module.prometheus]
}
