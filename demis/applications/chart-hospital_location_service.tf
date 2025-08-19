locals {
  hls_name = "hospital-location-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  hls_enabled = contains(local.service_names, local.hls_name) ? var.deployment_information[local.hls_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  hls_template_app   = fileexists("${var.external_chart_path}/${local.hls_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.hls_name}/${local.application_values_file}" : "${path.module}/${local.hls_name}/${local.application_values_file}"
  hls_template_istio = fileexists("${var.external_chart_path}/${local.hls_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.hls_name}/${local.istio_values_file}" : "${path.module}/${local.hls_name}/${local.istio_values_file}"
  # Define override for resources
  hls_resources_overrides = try(var.resource_definitions[local.hls_name], {})
  hls_replicas            = lookup(local.hls_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.hls_name].replicas : null
  hls_resource_block      = lookup(local.hls_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.hls_name].resource_block : null
}

module "hospital_location_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.hls_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.hls_name
  deployment_information = var.deployment_information[local.hls_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.hls_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    feature_flags      = try(var.feature_flags[local.hls_name], {}),
    config_options     = try(var.config_options[local.hls_name], {}),
    replica_count      = local.hls_replicas,
    resource_block     = local.hls_resource_block
  })
  istio_values = templatefile(local.hls_template_istio, {
    namespace                      = var.target_namespace,
    cluster_gateway                = var.cluster_gateway,
    context_path                   = var.context_path,
    demis_hostnames                = local.demis_hostnames,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.hls_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
