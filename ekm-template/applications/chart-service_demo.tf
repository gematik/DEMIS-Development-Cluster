locals {
  service_name = "service-demo"
  # Verify whether the service is defined or the deployment is explicitly enabled
  service_enabled = contains(local.service_names, local.service_name) ? var.deployment_information[local.service_name].enabled : false
  # Define override for resources
  service_resources_overrides = try(var.resource_definitions[local.service_name], {})
  service_replicas            = lookup(local.service_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.service_name].replicas : null
  service_resource_block      = lookup(local.service_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.service_name].resource_block : null
}

module "service_demo" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.service_name
  deployment_information = var.deployment_information[local.service_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.service_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    feature_flags         = try(var.feature_flags[local.service_name], {}),
    config_options        = try(var.config_options[local.service_name], {}),
    replica_count         = local.service_replicas,
    resource_block        = local.service_resource_block
    istio_proxy_resources = try(local.service_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  }), local.chart_files[local.service_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.service_name].istio_template, {
    namespace                = var.target_namespace,
    cluster_gateway          = var.cluster_gateway,
    context_path             = var.context_path,
    demis_hostnames          = local.demis_hostnames
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.service_name], null)
  }), local.chart_files[local.service_name].istio_values_override])
}
