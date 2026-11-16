# Retrieve the labels of the Istio namespace (created by the infrastructure),
# containing the stage and region of the cluster.
data "kubernetes_namespace_v1" "istio" {
  metadata {
    name = var.fallback_namespace
  }
}

# Istio version of the cluster, used for downloading the matching Istio Grafana Dashboards
data "kubernetes_resource" "istiod" {
  count       = local.grafana_enabled ? 1 : 0
  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name      = "istiod"
    namespace = var.fallback_namespace
  }
}

locals {
  istio_version  = try(data.kubernetes_resource.istiod[0].object.metadata.labels["app.kubernetes.io/version"], null)
  cluster_labels = data.kubernetes_namespace_v1.istio.metadata[0].labels
  stage_name     = local.cluster_labels.cluster
  cluster_region = local.cluster_labels.region
  # Stage folder as in the application modules: "local" for KIND (and public), otherwise <cluster>-<region>
  is_local_mode = contains(["local", "public"], local.stage_name)
  stage_folder  = var.override_stage_name != "" ? var.override_stage_name : (local.is_local_mode ? "local" : "${local.stage_name}-${local.cluster_region}")

  # Active Versions of the DEMIS charts (Audit Log Service, istio-routing); optional: without the file no DEMIS chart is deployed
  active_versions_source_path = "${path.module}/../environments/stage-${local.stage_folder}/observability/active-versions.yaml"
  active_versions             = try(yamldecode(file(local.active_versions_source_path)), {})
  # Always the canary version if one exists, main otherwise: handed over as main, canary is emptied (for every deployment strategy)
  deployment_information = { for name, info in local.active_versions : name => merge(info, {
    main = {
      version      = try(coalesce(info.canary.version), info.main.version)
      image-digest = try(info.canary.version, null) != null ? try(info.canary.image-digest, null) : try(info.main.image-digest, null)
      weight       = try(info.main.weight, 100)
    }
    canary = {}
  }) }

  # Helm Chart sources: repository name from the Helm repositories.yaml or null (module default URL)
  helm_use_local         = var.helm_repository_source == "local"
  helm_repository_by_key = { for k, v in var.helm_repository_names : k => local.helm_use_local ? v : null }
  # DEMIS Helm Repository: repository name from the Helm repositories.yaml or URL with credentials
  demis_helm_repository          = local.helm_use_local ? var.helm_repository_names.demis : var.demis_helm_repository
  demis_helm_repository_username = local.helm_use_local ? null : var.helm_repository_username
  demis_helm_repository_password = local.helm_use_local ? null : var.helm_repository_password

  # Switched together with the infrastructure: without FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED the legacy observability of the
  # infrastructure (service-mesh) is active and nothing is deployed here
  namespace_enabled = try(var.project_feature_flags["FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED"], false)

  # Versions (and digests) of the components from the active-versions.yaml, a component without entry or with enabled false is not deployed.
  # Prometheus, Grafana and Loki are deployed on local and public only.
  components         = { for name in ["kiali", "prometheus", "jaeger", "grafana", "loki"] : name => try(local.deployment_information[name], null) }
  kiali_enabled      = local.namespace_enabled && try(local.components.kiali.enabled, false)
  prometheus_enabled = local.namespace_enabled && local.is_local_mode && try(local.components.prometheus.enabled, false)
  jaeger_enabled     = local.namespace_enabled && try(local.components.jaeger.enabled, false)
  grafana_enabled    = local.namespace_enabled && local.is_local_mode && try(local.components.grafana.enabled, false)
  loki_enabled       = local.namespace_enabled && local.is_local_mode && try(local.components.loki.enabled, false)

  # Kiali and Jaeger always run in the observability namespace, with the in-mesh OTLP Service (TCP)
  kiali_jaeger_in_namespace = local.namespace_enabled

  # Audit Log Service: enabled in the active-versions.yaml and switched by the same project feature flags as in the demis module
  audit_log_service_deployment_information = try(local.deployment_information["audit-log-service"], null)
  audit_log_service_active                 = local.namespace_enabled && try(local.audit_log_service_deployment_information.enabled, false)
  audit_log_service_fssr_enabled           = local.audit_log_service_active && try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSR_ENABLED"], false)
  audit_log_service_fssw_enabled           = local.audit_log_service_active && try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSW_ENABLED"], false)
  audit_log_service_enabled                = local.audit_log_service_fssr_enabled || local.audit_log_service_fssw_enabled
}

module "kiali" {
  source                = "./kiali"
  kiali_version         = local.components.kiali.main.version
  kiali_helm_repository = local.helm_repository_by_key.kiali
  target_namespace      = local.kiali_jaeger_namespace
  # Define the Cluster-internal URL for Prometheus
  prometheus_service_url = local.prometheus_enabled ? module.prometheus[0].prometheus_service_url : var.prometheus_service_url
  # Define the Cluster-internal URL and Port for Tracing (Jaeger)
  tracing_service_url  = local.jaeger_enabled ? module.jaeger[0].tracing_service_url : var.tracing_service_url
  tracing_service_port = local.jaeger_enabled ? module.jaeger[0].grpc_query_port : "16685"
  # Define the Cluster-internal URL for Grafana
  grafana_service_url = local.grafana_enabled ? module.grafana[0].grafana_service_url : var.grafana_service_url
  # Define the Public URL for Grafana (might require Port-Forwarding)
  grafana_public_url = local.grafana_enabled ? module.grafana[0].grafana_public_url : var.grafana_public_url
  # Enable only if explicitly set
  count = local.kiali_enabled ? 1 : 0
}

module "prometheus" {
  source                     = "./prometheus"
  prometheus_version         = local.components.prometheus.main.version
  prometheus_helm_repository = local.helm_repository_by_key.prometheus
  target_namespace           = local.namespace
  # Enable only if explicitly set
  count = local.prometheus_enabled ? 1 : 0
}

module "jaeger" {
  source                 = "./jaeger"
  jaeger_version         = local.components.jaeger.main.version
  jaeger_digest          = local.components.jaeger.main.image-digest
  target_namespace       = local.kiali_jaeger_namespace
  jaeger_max_traces      = coalesce(var.jaeger_max_traces, "50000")
  jaeger_storage_backend = coalesce(var.jaeger_storage_backend, "memory")
  jaeger_ttl_spans       = coalesce(var.jaeger_ttl_spans, "48h")
  # TCP Service for the in-mesh OTLP exports, together with the move into the observability namespace
  internal_service_enabled = local.kiali_jaeger_in_namespace
  # Enable only if explicitly set
  count = local.jaeger_enabled ? 1 : 0
}

module "grafana" {
  source           = "./grafana"
  grafana_version  = local.components.grafana.main.version
  grafana_digest   = local.components.grafana.main.image-digest
  target_namespace = local.namespace
  # Enable only if explicitly set
  count = local.grafana_enabled ? 1 : 0
  # Used for downloading the Dashboards
  istio_version = local.istio_version
  # Enable the Loki datasource only if Loki is deployed
  loki_enabled = local.loki_enabled && local.grafana_enabled
  # Point the datasource at the topology-aware Loki service URL
  loki_service_url = local.loki_enabled && local.grafana_enabled ? module.loki[0].loki_service_url : ""
  # Loki must exist before Grafana so its datasource resolves on first start
  depends_on = [module.prometheus, module.loki]
}

module "loki" {
  source               = "./loki"
  loki_version         = local.components.loki.main.version
  loki_helm_repository = local.helm_repository_by_key.loki
  target_namespace     = local.namespace
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
  count = local.loki_enabled && local.grafana_enabled ? 1 : 0
}

module "audit_log_service" {
  source                 = "./audit-log-service"
  target_namespace       = local.namespace
  deployment_information = local.audit_log_service_deployment_information
  # Service and DestinationRule via the istio-routing chart, as in the application modules
  istio_routing_deployment_information = try(local.deployment_information["istio-routing"], null)
  helm_repository                      = local.demis_helm_repository
  helm_username                        = local.demis_helm_repository_username
  helm_password                        = local.demis_helm_repository_password
  docker_registry                      = var.audit_log_service_docker_registry
  image_pull_secrets                   = [for k, v in module.pull_secrets : v.metadata.name]
  replica_count                        = var.audit_log_service_replica_count
  audited_namespace                    = var.audit_log_service_audited_namespace
  fssr_enabled                         = local.audit_log_service_fssr_enabled
  fssw_enabled                         = local.audit_log_service_fssw_enabled
  # Deployed as soon as one of the audited workloads is enabled (active-versions.yaml and project feature flags)
  count = local.audit_log_service_enabled ? 1 : 0
}
