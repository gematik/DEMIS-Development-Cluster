locals {
  portal_shell_name = "portal-shell"
  # Verify whether the service is defined or the deployment is explicitly enabled
  portal_shell_enabled = contains(local.service_names, local.portal_shell_name) ? var.deployment_information[local.portal_shell_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  portal_shell_template_app   = fileexists("${var.external_chart_path}/${local.portal_shell_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.portal_shell_name}/${local.application_values_file}" : "${path.module}/${local.portal_shell_name}/${local.application_values_file}"
  portal_shell_template_istio = fileexists("${var.external_chart_path}/${local.portal_shell_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.portal_shell_name}/${local.istio_values_file}" : "${path.module}/${local.portal_shell_name}/${local.istio_values_file}"
  # Define override for resources
  portal_shell_resources_overrides = try(var.resource_definitions[local.portal_shell_name], {})
  portal_shell_replicas            = lookup(local.portal_shell_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.portal_shell_name].replicas : null
  portal_shell_resource_block      = lookup(local.portal_shell_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.portal_shell_name].resource_block : null
}

module "portal_shell" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.portal_shell_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.portal_shell_name
  deployment_information = var.deployment_information[local.portal_shell_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.portal_bedoccupancy[0], module.portal_disease[0], module.portal_pathogen[0], module.portal_igs[0]]

  # Pass the values for the chart
  application_values = templatefile(local.portal_shell_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    istio_enable                                       = var.istio_enabled,
    production_mode                                    = var.production_mode,
    csp_hostname                                       = "https://${var.portal_hostname}/ https://${var.meldung_hostname}/ https://${var.auth_hostname}/ https://${var.storage_hostname}/",
    meldung_hostname                                   = var.meldung_hostname,
    feature_flags                                      = try(var.feature_flags[local.portal_shell_name], {}),
    config_options                                     = try(var.config_options[local.portal_shell_name], {}),
    issuer_hostname                                    = var.auth_hostname,
    replica_count                                      = local.portal_shell_replicas,
    resource_block                                     = local.portal_shell_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.portal_shell_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.portal_shell_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.portal_shell_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    portal_hostnames               = local.frontend_hostnames
    feature_flag_new_api_endpoints = try(var.feature_flags[local.portal_shell_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
