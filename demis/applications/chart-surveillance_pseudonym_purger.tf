locals {
  ########################################
  # Surveilance Pseudonym Purger - Base  #
  ########################################
  spp_name = "surveillance-pseudonym-purger"

  ########################################
  # Surveilance Pseudonym Purger - ARS   #
  ########################################
  spp_ars_name                = "${local.spp_name}-ars"
  spp_ars_enabled             = contains(local.service_names, local.spp_ars_name) ? var.deployment_information[local.spp_ars_name].enabled : false
  spp_ars_template_app        = fileexists("${var.external_chart_path}/${local.spp_ars_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.spp_ars_name}/${local.application_values_file}" : "${path.module}/${local.spp_ars_name}/${local.application_values_file}"
  spp_ars_template_istio      = fileexists("${var.external_chart_path}/${local.spp_ars_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.spp_ars_name}/${local.istio_values_file}" : "${path.module}/${local.spp_ars_name}/${local.istio_values_file}"
  spp_ars_resources_overrides = try(var.resource_definitions[local.spp_ars_name], {})
  spp_ars_replicas            = lookup(local.spp_ars_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.spp_ars_name].replicas : null
  spp_ars_resource_block      = lookup(local.spp_ars_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.spp_ars_name].resource_block : null
}

module "surveillance_pseudonym_purger_ars" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.spp_ars_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.spp_ars_name
  deployment_information = var.deployment_information[local.spp_ars_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.spp_ars_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    suspend            = var.surveillance_pseudonym_purger_ars_suspend,
    cron_schedule      = var.surveillance_pseudonym_purger_ars_cron_schedule,
    feature_flags      = try(var.feature_flags[local.spp_ars_name], {}),
    config_options     = try(var.config_options[local.spp_ars_name], {}),
    replica_count      = local.spp_ars_replicas,
    resource_block     = local.spp_ars_resource_block
  })
  istio_values = templatefile(local.spp_ars_template_istio, {
    namespace = var.target_namespace
  })
}