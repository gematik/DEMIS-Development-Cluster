module "istio" {
  source                    = "./istio"
  chart_version             = var.istio_version
  local_deployment          = var.local_deployment
  local_node_ports_istio    = var.local_node_ports_istio
  namespace                 = var.namespace
  trace_sampling            = var.trace_sampling
  replica_count             = var.istio_replica_count
  external_ip               = var.external_ip
  ingress_annotations       = var.ingress_annotations
  loadbalancer_sourceranges = var.loadbalancer_sourceranges
}

module "kiali" {
  source           = "./kiali"
  kiali_version    = var.kiali_version
  target_namespace = var.namespace
  # Define the Cluster-internal URL for Prometheus
  prometheus_service_url = var.prometheus_enabled ? module.prometheus[0].prometheus_service_url : var.prometheus_service_url
  # Define the Cluster-internal URL and Port for Tracing (Jaeger)
  tracing_service_url  = var.jaeger_enabled ? module.jaeger[0].tracing_service_url : var.tracing_service_url
  tracing_service_port = var.jaeger_enabled ? module.jaeger[0].grpc_query_port : "16685"
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
  # Enable the Loki datasource only if Loki is deployed
  loki_enabled = var.loki_enabled && var.grafana_enabled
  # Point the datasource at the topology-aware Loki service URL
  loki_service_url = var.loki_enabled && var.grafana_enabled ? module.loki[0].loki_service_url : ""
  # Loki must exist before Grafana so its datasource resolves on first start
  depends_on = [module.prometheus, module.loki]
}

module "loki" {
  source           = "./loki"
  loki_version     = var.loki_version
  target_namespace = var.namespace
  # Deployment topology (Monolithic or SimpleScalable)
  loki_deployment_mode = var.loki_deployment_mode
  # Storage configuration (local filesystem or external S3)
  loki_storage_type         = var.loki_storage_type
  loki_s3_endpoint          = var.loki_s3_endpoint
  loki_s3_region            = var.loki_s3_region
  loki_s3_bucket_chunks     = var.loki_s3_bucket_chunks
  loki_s3_bucket_ruler      = var.loki_s3_bucket_ruler
  loki_s3_bucket_admin      = var.loki_s3_bucket_admin
  loki_s3_force_path_style  = var.loki_s3_force_path_style
  loki_s3_insecure          = var.loki_s3_insecure
  loki_s3_access_key_id     = var.loki_s3_access_key_id
  loki_s3_secret_access_key = var.loki_s3_secret_access_key
  loki_replicas             = var.loki_replicas
  loki_read_replicas        = var.loki_read_replicas
  loki_write_replicas       = var.loki_write_replicas
  loki_backend_replicas     = var.loki_backend_replicas
  loki_retention_period     = var.loki_retention_period
  # Only deploy Loki if explicitly enabled AND Grafana is installed
  count = var.loki_enabled && var.grafana_enabled ? 1 : 0
  # Deploy Loki before Grafana; only the mesh is required beforehand
  depends_on = [module.istio]
}
