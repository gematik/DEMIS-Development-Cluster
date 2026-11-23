locals {
  audit_log_purger_name = "audit-log-purger"
  # Deployed if enabled in the active-versions.yaml
  audit_log_purger_deployment_information = try(var.deployment_information[local.audit_log_purger_name], { main = { version = "0.0.0" }, enabled = false })
  audit_log_purger_enabled                = try(local.audit_log_purger_deployment_information.enabled, false)

  alp_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "fetched-notifications-purger-database-secret"
    ),
    -1 # Default index if not found
  )
}

# CronJob purging the fetched_notifications of the Audit Log Service
module "audit_log_purger" {
  source = "../../modules/helm_deployment"

  # Deployed if enabled in the active-versions.yaml
  count = local.audit_log_purger_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.audit_log_purger_name
  deployment_information = local.audit_log_purger_deployment_information
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.audit_log_service[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.audit_log_purger_name].app_template, {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.pull_secrets
    debug_enable       = var.debug_enabled
    suspend            = var.audit_log_purger_suspend
    cron_schedule      = var.audit_log_purger_cron_schedule
    data_base          = local.db_name
    namespace          = var.target_namespace
    # Resources and sidecar resources (resources.tfvars), a CronJob has no replicas
    resource_block        = var.resource_definitions[local.audit_log_purger_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.audit_log_purger_name].istio_proxy_resources
    # Feature flags and config options (feature_flags.tfvars, config_options.tfvars)
    feature_flags  = lookup(var.feature_flags, local.audit_log_purger_name, {})
    config_options = lookup(var.config_options, local.audit_log_purger_name, {})
    # Restart on changed credentials
    db_secret_checksum = try(kubernetes_secret_v1.database_credentials[local.alp_index].metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.audit_log_purger_name].app_values_override])

  # CronJob without Service and Istio resources
  istio_values = compact([templatefile(local.chart_files[local.audit_log_purger_name].istio_template, {
    namespace = var.target_namespace,
    app_name  = local.audit_log_purger_name
  }), local.chart_files[local.audit_log_purger_name].istio_values_override])

}
