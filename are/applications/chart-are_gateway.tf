locals {
  are_gateway_name = "are-gateway"
  # Verify whether the service is defined or the deployment is explicitly enabled
  are_gateway_enabled = contains(local.service_names, local.are_gateway_name) ? var.deployment_information[local.are_gateway_name].enabled : false
  # Define override for resources
  are_gateway_resources_overrides = try(var.resource_definitions[local.are_gateway_name], {})
  are_gateway_replicas            = lookup(local.are_gateway_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.are_gateway_name].replicas : null
  are_gateway_resource_block      = lookup(local.are_gateway_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.are_gateway_name].resource_block : null
}

module "notification_are_gateway" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.are_gateway_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.are_gateway_name
  deployment_information = var.deployment_information[local.are_gateway_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.are_notification_processing_service[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.are_gateway_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    portal_hostname       = var.portal_hostname,
    meldung_hostname      = var.meldung_hostname,
    core_hostname         = var.core_hostname,
    issuer_hostname       = var.auth_hostname,
    context_path          = var.context_path,
    feature_flags         = try(var.feature_flags[local.are_gateway_name], {}),
    config_options        = try(var.config_options[local.are_gateway_name], {}),
    replica_count         = local.are_gateway_replicas,
    resource_block        = local.are_gateway_resource_block,
    istio_proxy_resources = try(local.are_gateway_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  }), local.chart_files[local.are_gateway_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.are_gateway_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    portal_hostnames           = local.frontend_hostnames,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.are_gateway_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.are_gateway_name], [])
  }), local.chart_files[local.are_gateway_name].istio_values_override])
}
