locals {
  portal_are_name = "portal-are"
  # Verify whether the service is defined or the deployment is explicitly enabled
  portal_are_enabled = contains(local.service_names, local.portal_are_name) ? var.deployment_information[local.portal_are_name].enabled : false
  # Define override for resources
  portal_are_resources_overrides = try(var.resource_definitions[local.portal_are_name], {})
  portal_are_replicas            = lookup(local.portal_are_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.portal_are_name].replicas : null
  portal_are_resource_block      = lookup(local.portal_are_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.portal_are_name].resource_block : null
}

module "portal_are" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.portal_are_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.portal_are_name
  deployment_information = var.deployment_information[local.portal_are_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.portal_are_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    istio_enable          = var.istio_enabled,
    context_path          = var.context_path,
    csp_hostname          = "https://${var.portal_hostname}/ https://${var.meldung_hostname}/ https://${var.auth_hostname}/",
    feature_flags         = try(var.feature_flags[local.portal_are_name], {}),
    config_options        = try(var.config_options[local.portal_are_name], {}),
    replica_count         = local.portal_are_replicas,
    resource_block        = local.portal_are_resource_block
    istio_proxy_resources = try(local.portal_are_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  }), local.chart_files[local.portal_are_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.portal_are_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    portal_hostnames           = local.frontend_hostnames,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.portal_are_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.portal_are_name], [])
  }), local.chart_files[local.portal_are_name].istio_values_override])
}
