locals {
  nrs_name = "notification-routing-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  nrs_enabled = contains(local.service_names, local.nrs_name) ? var.deployment_information[local.nrs_name].enabled : false
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
  application_values = compact([templatefile(local.chart_files[local.nrs_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    routing_data_version  = local.routing_data_version,
    feature_flags         = try(var.feature_flags[local.nrs_name], {}),
    config_options        = try(var.config_options[local.nrs_name], {}),
    replica_count         = var.resource_definitions[local.nrs_name].replicas,
    resource_block        = var.resource_definitions[local.nrs_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.nrs_name].istio_proxy_resources,
  }), local.chart_files[local.nrs_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.nrs_name].istio_template, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.nrs_name], null)
  }), local.chart_files[local.nrs_name].istio_values_override])
}
