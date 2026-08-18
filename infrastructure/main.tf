########################
# Define Modules
########################

locals {
  kubeconfig_path    = var.local_cluster ? module.local_cluster[0].kubeconfig_path : var.kubeconfig_path
  kms_encryption_key = length(var.kms_encryption_key) > 0 ? true : false

  # retrieve the name of the pull secret from the given docker registry credentials (local)
  pull_secrets_credentials = [for k, v in module.pull_secrets : v.metadata.name]
}

# Configure a KIND cluster locally
module "local_cluster" {
  source                      = "./local-cluster-setup"
  count                       = var.local_cluster ? 1 : 0
  kind_image_tag              = var.kind_image_tag
  kind_cluster_name           = var.kind_cluster_name
  kind_worker_nodes           = var.kind_worker_nodes
  kind_service_subnet_address = var.kind_service_subnet_address
}

# Configure a remote cluster
module "remote_cluster" {
  source               = "./remote-cluster-setup"
  count                = var.local_cluster ? 0 : 1
  service_account_name = var.service_account_name
  cluster_role_name    = var.cluster_role_name
}

# Configure Service-Mesh
module "service_mesh" {
  source           = "./service-mesh"
  namespace        = module.istio_namespace.name
  local_deployment = var.local_cluster
  # Configure Istio
  istio_version       = var.service_mesh_istio_version
  istio_replica_count = var.local_cluster ? var.kind_worker_nodes : var.service_mesh_istiod_replica_count
  # Configure Monitoring
  grafana_enabled    = var.service_mesh_monitoring_enabled
  grafana_version    = var.service_mesh_grafana_version
  grafana_digest     = var.service_mesh_grafana_digest
  prometheus_enabled = var.service_mesh_monitoring_enabled
  prometheus_version = var.service_mesh_prometheus_version
  # Configure Loki (only deployed together with Grafana)
  loki_enabled              = var.service_mesh_loki_enabled
  loki_version              = var.service_mesh_loki_version
  loki_deployment_mode      = var.service_mesh_loki_deployment_mode
  loki_storage_type         = var.service_mesh_loki_storage_type
  loki_s3_endpoint          = var.service_mesh_loki_s3_endpoint
  loki_s3_region            = var.service_mesh_loki_s3_region
  loki_s3_bucket_chunks     = var.service_mesh_loki_s3_bucket_chunks
  loki_s3_bucket_ruler      = var.service_mesh_loki_s3_bucket_ruler
  loki_s3_bucket_admin      = var.service_mesh_loki_s3_bucket_admin
  loki_s3_force_path_style  = var.service_mesh_loki_s3_force_path_style
  loki_s3_insecure          = var.service_mesh_loki_s3_insecure
  loki_s3_access_key_id     = var.loki_s3_access_key_id
  loki_s3_secret_access_key = var.loki_s3_secret_access_key
  loki_replicas             = var.service_mesh_loki_replicas
  loki_read_replicas        = var.service_mesh_loki_read_replicas
  loki_write_replicas       = var.service_mesh_loki_write_replicas
  loki_backend_replicas     = var.service_mesh_loki_backend_replicas
  loki_retention_period     = var.service_mesh_loki_retention_period
  # Set Trace Sampling
  jaeger_version         = var.service_mesh_jaeger_version
  jaeger_digest          = var.service_mesh_jaeger_digest
  trace_sampling         = var.service_mesh_tracing_sampling
  jaeger_max_traces      = var.jaeger_max_traces
  jaeger_storage_backend = var.jaeger_storage_backend
  jaeger_ttl_spans       = var.jaeger_ttl_spans
  # Configure Kiali
  kiali_version          = var.service_mesh_kiali_version
  grafana_service_url    = var.service_mesh_grafana_url
  prometheus_service_url = var.prometheus_service_url
  # Define External IP for the Istio Ingress Gateway
  external_ip = var.service_mesh_external_ip
  # Define Ingress Annotations for the Istio Ingress Gateway
  ingress_annotations       = var.service_mesh_ingress_annotations
  loadbalancer_sourceranges = var.service_mesh_loadbalancer_sourceranges
}

# Configure Trivy
module "trivy" {
  count     = var.trivy_enabled ? 1 : 0
  source    = "./security/trivy"
  namespace = module.security_namespace.name
  # Configure Trivy settings
  chart_version                 = var.trivy_chart_version
  additional_report_fields      = var.trivy_additional_report_fields
  cron_job_schedule             = var.trivy_cron_job_schedule
  scan_namespaces               = var.trivy_scan_namespaces
  ignore_unfixed                = var.trivy_ignore_unfixed
  private_registry_secret_names = var.trivy_private_registry_secret_names
  scan_jobs_limit               = var.trivy_scan_jobs_limit
  severity_levels               = var.trivy_severity_levels
  use_less_resources            = var.trivy_use_less_resources
}

# Configure Falco
module "falco" {
  count                     = var.falco_enabled ? 1 : 0
  source                    = "./security/falco"
  namespace                 = module.security_namespace.name
  chart_version             = var.falco_chart_version
  kubernetes_meta_collector = var.falco_kubernetes_meta_collector
  falcosidekick_enabled     = var.falco_falcosidekick_enabled
  falcosidekick_ui_enabled  = var.falco_falcosidekick_ui_enabled
  driver_kind               = var.falco_driver_kind
}

module "kyverno" {
  count                         = var.kyverno_enabled ? 1 : 0
  source                        = "./kyverno-controller"
  namespace                     = module.kyverno_namespace.name
  chart_version                 = var.kyverno_chart_version
  pull_secrets                  = local.pull_secrets_credentials
  admissioncontroller_replicas  = var.kyverno_admissioncontroller_replicas
  backgroundcontroller_replicas = var.kyverno_backgroundcontroller_replicas
  cleanupcontroller_replicas    = var.kyverno_cleanupcontroller_replicas
  reportscontroller_replicas    = var.kyverno_reportscontroller_replicas
}

module "kyverno_policy_reporter" {
  count         = var.kyverno_policy_reporter_enabled ? 1 : 0
  source        = "./security/policy-reporter"
  namespace     = module.security_namespace.name
  chart_version = var.kyverno_policy_reporter_chart_version
  depends_on    = [module.kyverno]
}
