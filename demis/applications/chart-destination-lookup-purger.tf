locals {
  dls_purger_name           = "destination-lookup-purger"
  dls_purger_information    = try(var.deployment_information[local.dls_purger_name], { enabled = false, main = { version = "" } })
  dls_purger_template_app   = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}" : "${path.module}/${local.dls_purger_name}/${local.application_values_file}"
  dls_purger_template_istio = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}" : "${path.module}/${local.dls_purger_name}/${local.istio_values_file}"

  # Define override for resources
  dlsp_resources_overrides = try(var.resource_definitions[local.dls_purger_name], {})
  dlsp_replicas            = lookup(local.dlsp_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_purger_name].replicas : null
  dlsp_resource_block      = lookup(local.dlsp_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_purger_name].resource_block : null
}


module "destination_lookup_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.dls_purger_information.enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.dls_purger_name
  deployment_information = local.dls_purger_information
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.destination_lookup_writer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.dls_purger_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    suspend            = var.destination_lookup_purger_suspend,
    cron_schedule      = var.destination_lookup_purger_cron_schedule,
    feature_flags      = try(var.feature_flags[local.dls_purger_name], {}),
    config_options     = try(var.config_options[local.dls_purger_name], {}),
    replica_count      = local.dlsp_replicas,
    resource_block     = local.dlsp_resource_block
  })
  istio_values = templatefile(local.dls_purger_template_istio, {
    namespace = var.target_namespace,
    app_name  = local.dls_purger_name
  })
}
