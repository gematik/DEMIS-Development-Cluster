locals {
  db_name                = "fetched_notifications"
  audit_log_service_name = "audit-log-service"
  # Deployed if enabled in the active-versions.yaml
  audit_log_service_deployment_information = try(var.deployment_information[local.audit_log_service_name], { main = { version = "0.0.0" }, enabled = false })
  audit_log_service_enabled                = try(local.audit_log_service_deployment_information.enabled, false)
  # The project feature flags only switch the ext_proc filters at the audited workloads
  audit_log_service_fssr_enabled = try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSR_ENABLED"], false)
  audit_log_service_fssw_enabled = try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSW_ENABLED"], false)

  # gRPC port of ext_proc
  audit_log_service_port = 50051

  als_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "fetched-notifications-user-ddl-database-secret"
    ),
    -1 # Default index if not found
  )

  als_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "fetched-notifications-user-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "audit_log_service" {
  source = "../../modules/helm_deployment"

  # Deployed if enabled in the active-versions.yaml
  count = local.audit_log_service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.audit_log_service_name
  deployment_information = local.audit_log_service_deployment_information
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.audit_log_service_name].app_template, {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.pull_secrets
    debug_enable       = var.debug_enabled
    port               = local.audit_log_service_port
    # Root namespace: the audited workloads live in another namespace than this service
    filter_namespace   = "istio-system"
    audited_namespaces = var.audit_log_service_audited_namespaces
    fssr_enabled       = local.audit_log_service_fssr_enabled
    fssw_enabled       = local.audit_log_service_fssw_enabled
    data_base          = local.db_name
    namespace          = var.target_namespace
    # Replicas, resources and sidecar resources (resources.tfvars)
    resource_block        = var.resource_definitions[local.audit_log_service_name].resource_block,
    replica_count         = var.resource_definitions[local.audit_log_service_name].replicas,
    istio_proxy_resources = var.resource_definitions[local.audit_log_service_name].istio_proxy_resources,
    # Feature flags and config options (feature_flags.tfvars, config_options.tfvars)
    feature_flags          = lookup(var.feature_flags, local.audit_log_service_name, {})
    config_options         = lookup(var.config_options, local.audit_log_service_name, {})
    db_secret_checksum     = try(kubernetes_secret_v1.database_credentials[local.als_index].metadata[0].annotations["checksum"], ""),
    db_ddl_secret_checksum = try(kubernetes_secret_v1.database_credentials[local.als_ddl_index].metadata[0].annotations["checksum"], ""),
  }), local.chart_files[local.audit_log_service_name].app_values_override])

  # Service of the ext_proc gRPC port (cluster outbound|50051||audit-log-service.<namespace>)
  istio_values = compact([templatefile(local.chart_files[local.audit_log_service_name].istio_template, {
    app_name  = local.audit_log_service_name
    namespace = var.target_namespace
    port      = local.audit_log_service_port
  }), local.chart_files[local.audit_log_service_name].istio_values_override])
}
