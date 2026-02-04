locals {
  nrs_name = "notification-routing-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  nrs_enabled = contains(local.service_names, local.nrs_name) ? var.deployment_information[local.nrs_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  nrs_template_app   = fileexists("${var.external_chart_path}/${local.nrs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.nrs_name}/${local.application_values_file}" : "${path.module}/${local.nrs_name}/${local.application_values_file}"
  nrs_template_istio = fileexists("${var.external_chart_path}/${local.nrs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.nrs_name}/${local.istio_values_file}" : "${path.module}/${local.nrs_name}/${local.istio_values_file}"
  # Define override for resources
  nrs_resources_overrides = try(var.resource_definitions[local.nrs_name], {})
  nrs_replicas            = lookup(local.nrs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.nrs_name].replicas : null
  nrs_resource_block      = lookup(local.nrs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.nrs_name].resource_block : null
}

module "notification_routing_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.nrs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.nrs_name
  deployment_information = var.deployment_information[local.nrs_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.nrs_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    routing_data_version                               = local.routing_data_version,
    feature_flags                                      = try(var.feature_flags[local.nrs_name], {}),
    config_options                                     = try(var.config_options[local.nrs_name], {}),
    replica_count                                      = local.nrs_replicas,
    resource_block                                     = local.nrs_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.nrs_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.nrs_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.nrs_template_istio, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.nrs_name], null)
  })
}
