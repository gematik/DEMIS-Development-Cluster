########################
# Define Modules
########################

locals {
  kms_encryption_key = length(var.kms_encryption_key) > 0 ? true : false

  # Helm Chart sources: repository name from the Helm repositories.yaml or null (module default URL)
  helm_use_local         = var.helm_repository_source == "local"
  helm_repository_by_key = { for k, v in var.helm_repository_names : k => local.helm_use_local ? v : null }

  # Switch from the legacy observability (service-mesh) to the observability module (make <stage> observability)
  observability_namespace_enabled = try(var.project_feature_flags["FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED"], false)
  # Namespace of Jaeger (tracing provider of istiod): the observability module runs it in its own namespace
  kiali_jaeger_namespace = local.observability_namespace_enabled ? var.observability_namespace : var.service_mesh_namespace
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
  cluster_name     = format("%s-%s", var.stage_name, var.cluster_region)
  namespace        = var.service_mesh_namespace
  stage_name       = var.stage_name
  cluster_region   = var.cluster_region
  local_deployment = var.local_cluster
  # Configure Istio
  istio_version         = var.service_mesh_istio_version
  istio_replica_count   = var.local_cluster ? var.kind_worker_nodes : var.service_mesh_istiod_replica_count
  istio_helm_repository = local.helm_use_local ? var.helm_repository_names.istio : var.service_mesh_istio_helm_repository
  # Set Trace Sampling and the namespace of the OTLP collector (Jaeger)
  trace_sampling    = var.service_mesh_tracing_sampling
  tracing_namespace = local.kiali_jaeger_namespace
  # Legacy observability, removed when the observability module is switched on
  observability_namespace_enabled = local.observability_namespace_enabled
  # Helm Repositories of the monitoring charts
  kiali_helm_repository      = local.helm_repository_by_key.kiali
  prometheus_helm_repository = local.helm_repository_by_key.prometheus
  loki_helm_repository       = local.helm_repository_by_key.loki
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
  # Configure Jaeger
  jaeger_version         = var.service_mesh_jaeger_version
  jaeger_digest          = var.service_mesh_jaeger_digest
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

  # Wait for the kubeconfig to exist AND for the kube-apiserver to be ready
  # after the ResourceQuota admission-plugin patch (local KIND clusters only).
  depends_on = [module.remote_cluster, module.local_cluster]
}

# Configure the security tools (Trivy, Falco, Kyverno Policy Reporter)
module "security" {
  source         = "./security"
  namespace      = var.security_namespace
  stage_name     = var.stage_name
  cluster_region = var.cluster_region
  # Configure Trivy
  trivy_enabled                       = var.trivy_enabled
  trivy_helm_repository               = local.helm_repository_by_key.trivy
  trivy_chart_version                 = var.trivy_chart_version
  trivy_additional_report_fields      = var.trivy_additional_report_fields
  trivy_cron_job_schedule             = var.trivy_cron_job_schedule
  trivy_scan_namespaces               = var.trivy_scan_namespaces
  trivy_ignore_unfixed                = var.trivy_ignore_unfixed
  trivy_private_registry_secret_names = var.trivy_private_registry_secret_names
  trivy_scan_jobs_limit               = var.trivy_scan_jobs_limit
  trivy_severity_levels               = var.trivy_severity_levels
  trivy_use_less_resources            = var.trivy_use_less_resources
  # Configure Falco
  falco_enabled                   = var.falco_enabled
  falco_helm_repository           = local.helm_repository_by_key.falco
  falco_chart_version             = var.falco_chart_version
  falco_kubernetes_meta_collector = var.falco_kubernetes_meta_collector
  falco_falcosidekick_enabled     = var.falco_falcosidekick_enabled
  falco_falcosidekick_ui_enabled  = var.falco_falcosidekick_ui_enabled
  falco_driver_kind               = var.falco_driver_kind
  # Configure the Kyverno Policy Reporter
  policy_reporter_enabled         = var.kyverno_policy_reporter_enabled
  policy_reporter_helm_repository = local.helm_repository_by_key.policy_reporter
  policy_reporter_chart_version   = var.kyverno_policy_reporter_chart_version

  # The Policy Reporter needs Kyverno
  depends_on = [module.remote_cluster, module.local_cluster, module.kyverno]
}

# Kyverno; namespace and pull secrets are created even if Kyverno is disabled
module "kyverno" {
  source                        = "./kyverno-controller"
  enabled                       = var.kyverno_enabled
  helm_repository               = local.helm_repository_by_key.kyverno
  namespace                     = var.kyverno_namespace
  chart_version                 = var.kyverno_chart_version
  docker_pull_secrets           = var.docker_pull_secrets
  google_cloud_access_token     = var.google_cloud_access_token
  admissioncontroller_replicas  = var.kyverno_admissioncontroller_replicas
  backgroundcontroller_replicas = var.kyverno_backgroundcontroller_replicas
  cleanupcontroller_replicas    = var.kyverno_cleanupcontroller_replicas
  reportscontroller_replicas    = var.kyverno_reportscontroller_replicas

  depends_on = [module.remote_cluster, module.local_cluster]
}
