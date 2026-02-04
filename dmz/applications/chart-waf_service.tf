locals {
  waf_name = "waf-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  waf_enabled = contains(local.service_names, local.waf_name) ? var.deployment_information[local.waf_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  waf_template_app   = fileexists("${var.external_chart_path}/${local.waf_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.waf_name}/${local.application_values_file}" : "${path.module}/${local.waf_name}/${local.application_values_file}"
  waf_template_istio = fileexists("${var.external_chart_path}/${local.waf_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.waf_name}/${local.istio_values_file}" : "${path.module}/${local.waf_name}/${local.istio_values_file}"
  # Define override for resources
  waf_resources_overrides = try(var.resource_definitions[local.waf_name], {})
  waf_replicas            = lookup(local.waf_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.waf_name].replicas : null
  waf_resource_block      = lookup(local.waf_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.waf_name].resource_block : null
}

module "waf_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.waf_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.waf_name
  deployment_information = var.deployment_information[local.waf_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.secure_message_gateway[0]]

  # Pass the values for the chart
  application_values = templatefile(local.waf_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    feature_flags                                      = try(var.feature_flags[local.waf_name], {}),
    config_options                                     = try(var.config_options[local.waf_name], {}),
    replica_count                                      = local.waf_replicas,
    resource_block                                     = local.waf_resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.waf_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false),
    istio_proxy_resources                              = try(local.waf_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources),
    secure_message_gateway_url                         = var.secure_message_gateway_url
  })
  istio_values = templatefile(local.waf_template_istio, {
    namespace                = var.target_namespace,
    context_path             = var.context_path,
    cluster_gateway          = var.cluster_gateway,
    demis_hostnames          = local.demis_hostnames,
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.waf_name], null)
  })
}
