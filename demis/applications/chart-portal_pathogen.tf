locals {
  portal_pathogen_name = "portal-pathogen"
  # Verify whether the service is defined or the deployment is explicitly enabled
  portal_pathogen_enabled = contains(local.service_names, local.portal_pathogen_name) ? var.deployment_information[local.portal_pathogen_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  portal_pathogen_template_app   = fileexists("${var.external_chart_path}/${local.portal_pathogen_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.portal_pathogen_name}/${local.application_values_file}" : "${path.module}/${local.portal_pathogen_name}/${local.application_values_file}"
  portal_pathogen_template_istio = fileexists("${var.external_chart_path}/${local.portal_pathogen_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.portal_pathogen_name}/${local.istio_values_file}" : "${path.module}/${local.portal_pathogen_name}/${local.istio_values_file}"
  # Define override for resources
  portal_pathogen_resources_overrides = try(var.resource_definitions[local.portal_pathogen_name], {})
  portal_pathogen_replicas            = lookup(local.portal_pathogen_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.portal_pathogen_name].replicas : null
  portal_pathogen_resource_block      = lookup(local.portal_pathogen_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.portal_pathogen_name].resource_block : null
}

module "portal_pathogen" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.portal_pathogen_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.portal_pathogen_name
  deployment_information = var.deployment_information[local.portal_pathogen_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.notification_gateway[0]]

  # Pass the values for the chart
  application_values = templatefile(local.portal_pathogen_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    istio_enable       = var.istio_enabled,
    production_mode    = var.production_mode,
    csp_hostname       = "https://${var.portal_hostname}/ https://${var.meldung_hostname}/ https://${var.auth_hostname}/ https://${var.storage_hostname}/",
    feature_flags      = try(var.feature_flags[local.portal_pathogen_name], {}),
    config_options     = try(var.config_options[local.portal_pathogen_name], {}),
    replica_count      = local.portal_pathogen_replicas,
    resource_block     = local.portal_pathogen_resource_block
  })
  istio_values = templatefile(local.portal_pathogen_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    portal_hostnames               = local.frontend_hostnames
    feature_flag_new_api_endpoints = try(var.feature_flags[local.portal_pathogen_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
