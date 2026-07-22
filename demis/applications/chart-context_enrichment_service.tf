locals {
  ces_name = "context-enrichment-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  ces_enabled = contains(local.service_names, local.ces_name) ? var.deployment_information[local.ces_name].enabled : false
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
  application_values = compact([templatefile(local.chart_files[local.ces_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    feature_flags         = try(var.feature_flags[local.ces_name], {}),
    config_options        = try(var.config_options[local.ces_name], {}),
    replica_count         = var.resource_definitions[local.ces_name].replicas,
    resource_block        = var.resource_definitions[local.ces_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.ces_name].istio_proxy_resources,
  }), local.chart_files[local.ces_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.ces_name].istio_template, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.ces_name], null)
  }), local.chart_files[local.ces_name].istio_values_override])
}
