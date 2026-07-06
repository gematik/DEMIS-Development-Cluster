locals {
  ########################################
  # Bulk Inbound Purger  #
  ########################################
  bip_name           = "bulk-inbound-purger"
  bip_enabled        = contains(local.service_names, local.bip_name) ? var.deployment_information[local.bip_name].enabled : false
  bip_template_app   = fileexists("${var.external_chart_path}/${local.bip_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.bip_name}/${local.application_values_file}" : "${path.module}/${local.bip_name}/${local.application_values_file}"
  bip_template_istio = fileexists("${var.external_chart_path}/${local.bip_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.bip_name}/${local.istio_values_file}" : "${path.module}/${local.bip_name}/${local.istio_values_file}"
}

module "bulk_inbound_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.bip_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.bip_name
  deployment_information = var.deployment_information[local.bip_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.bulk_inbound_service[0]]

  # Pass the values for the chart
  application_values = templatefile(local.bip_template_app, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    suspend               = var.bulk_inbound_purger_suspend,
    cron_schedule         = var.bulk_inbound_purger_cron_schedule,
    feature_flags         = try(var.feature_flags[local.bip_name], {}),
    config_options        = try(var.config_options[local.bip_name], {}),
    replica_count         = var.resource_definitions[local.bip_name].replicas,
    resource_block        = var.resource_definitions[local.bip_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.bip_name].istio_proxy_resources,
  })
  istio_values = templatefile(local.bip_template_istio, {
    namespace = var.target_namespace
  })
}
