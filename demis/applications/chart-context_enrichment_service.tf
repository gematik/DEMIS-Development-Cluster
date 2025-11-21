locals {
  ces_name = "context-enrichment-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  ces_enabled = contains(local.service_names, local.ces_name) ? var.deployment_information[local.ces_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  ces_template_app   = fileexists("${var.external_chart_path}/${local.ces_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.ces_name}/${local.application_values_file}" : "${path.module}/${local.ces_name}/${local.application_values_file}"
  ces_template_istio = fileexists("${var.external_chart_path}/${local.ces_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.ces_name}/${local.istio_values_file}" : "${path.module}/${local.ces_name}/${local.istio_values_file}"
  # Define override for resources
  ces_resources_overrides = try(var.resource_definitions[local.ces_name], {})
  ces_replicas            = lookup(local.ces_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.ces_name].replicas : null
  ces_resource_block      = lookup(local.ces_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.ces_name].resource_block : null
}

module "context_enrichment_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.ces_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.ces_name
  deployment_information = var.deployment_information[local.ces_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.ces_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    feature_flags                                      = try(var.feature_flags[local.ces_name], {}),
    config_options                                     = try(var.config_options[local.ces_name], {}),
    replica_count                                      = local.ces_replicas,
    resource_block                                     = local.ces_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.ces_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.ces_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.ces_template_istio, {
    namespace = var.target_namespace
  })
}
