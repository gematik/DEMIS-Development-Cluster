########################
# Define Modules
########################

locals {
  kubeconfig_path    = var.local_cluster ? module.local_cluster[0].kubeconfig_path : var.kubeconfig_path
  kms_encryption_key = length(var.kms_encryption_key) > 0 ? true : false
}

# Configure a KIND cluster locally
module "local_cluster" {
  source            = "./local-cluster-setup"
  count             = var.local_cluster ? 1 : 0
  kind_image_tag    = var.kind_image_tag
  kind_cluster_name = var.kind_cluster_name
  kind_worker_nodes = var.kind_worker_nodes
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
  # Set Trace Sampling
  jaeger_version = var.service_mesh_jaeger_version
  jaeger_digest  = var.service_mesh_jaeger_digest
  trace_sampling = var.service_mesh_tracing_sampling
  # Configure Kiali
  kiali_version          = var.service_mesh_kiali_version
  grafana_service_url    = var.service_mesh_grafana_url
  prometheus_service_url = var.prometheus_service_url
  # Define External IP for the Istio Ingress Gateway
  external_ip = var.service_mesh_external_ip
}

# Configure Trivy
module "trivy" {
  count     = var.trivy_enabled ? 1 : 0
  source    = "./security/trivy"
  namespace = module.security_namespace.name
  # Configure Trivy settings
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
  kubernetes_meta_collector = var.falco_kubernetes_meta_collector
  falcosidekick_enabled     = var.falco_falcosidekick_enabled
  falcosidekick_ui_enabled  = var.falco_falcosidekick_ui_enabled
  driver_kind               = var.falco_driver_kind
}

module "kyverno" {
  count                         = var.kyverno_enabled ? 1 : 0
  source                        = "./kyverno-controller"
  namespace                     = module.kyverno_namespace.name
  admissioncontroller_replicas  = var.kyverno_admissioncontroller_replicas
  backgroundcontroller_replicas = var.kyverno_backgroundcontroller_replicas
  cleanupcontroller_replicas    = var.kyverno_cleanupcontroller_replicas
  reportscontroller_replicas    = var.kyverno_reportscontroller_replicas
}

module "kyverno_policy_reporter" {
  count      = var.kyverno_policy_reporter_enabled ? 1 : 0
  source     = "./security/policy-reporter"
  namespace  = module.security_namespace.name
  depends_on = [module.kyverno]
}