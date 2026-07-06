locals {
  ########################################
  # ars purger  #
  ########################################
  ars_purger_name           = "ars-purger"
  ars_purger_enabled        = contains(local.service_names, local.ars_purger_name) ? var.deployment_information[local.ars_purger_name].enabled : false
  ars_purger_template_app   = fileexists("${var.external_chart_path}/${local.ars_purger_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.ars_purger_name}/${local.application_values_file}" : "${path.module}/${local.ars_purger_name}/${local.application_values_file}"
  ars_purger_template_istio = fileexists("${var.external_chart_path}/${local.ars_purger_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.ars_purger_name}/${local.istio_values_file}" : "${path.module}/${local.ars_purger_name}/${local.istio_values_file}"
}

module "ars_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.ars_purger_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.ars_purger_name
  deployment_information = var.deployment_information[local.ars_purger_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.ars_service[0]]

  # Pass the values for the chart
  application_values = templatefile(local.ars_purger_template_app, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    suspend               = var.ars_purger_suspend,
    cron_schedule         = var.ars_purger_cron_schedule,
    feature_flags         = try(var.feature_flags[local.ars_purger_name], {}),
    config_options        = try(var.config_options[local.ars_purger_name], {}),
    replica_count         = var.resource_definitions[local.ars_purger_name].replicas,
    resource_block        = var.resource_definitions[local.ars_purger_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.ars_purger_name].istio_proxy_resources,
  })
  istio_values = templatefile(local.ars_purger_template_istio, {
    namespace = var.target_namespace
  })
}
