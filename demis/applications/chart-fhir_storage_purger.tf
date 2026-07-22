locals {
  fsp_name = "fhir-storage-purger"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fsp_enabled = contains(local.service_names, local.fsp_name) ? var.deployment_information[local.fsp_name].enabled : false
}

module "fhir_storage_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fsp_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fsp_name
  deployment_information = var.deployment_information[local.fsp_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.fhir_storage_writer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.fsp_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    suspend               = var.fhir_storage_purger_suspend,
    cron_schedule         = var.fhir_storage_purger_cron_schedule,
    feature_flags         = try(var.feature_flags[local.fsp_name], {}),
    config_options        = try(var.config_options[local.fsp_name], {}),
    replica_count         = var.resource_definitions[local.fsp_name].replicas,
    resource_block        = var.resource_definitions[local.fsp_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.fsp_name].istio_proxy_resources,
  }), local.chart_files[local.fsp_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.fsp_name].istio_template, {
    namespace = var.target_namespace
  }), local.chart_files[local.fsp_name].istio_values_override])
}
