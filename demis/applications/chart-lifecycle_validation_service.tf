locals {
  lcvs_name = "lifecycle-validation-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  lcvs_enabled = contains(local.service_names, local.lcvs_name) ? var.deployment_information[local.lcvs_name].enabled : false
}

module "lifecycle_validation_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.lcvs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.lcvs_name
  deployment_information = var.deployment_information[local.lcvs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [helm_release.futs[0]]
  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.lcvs_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    feature_flags         = try(var.feature_flags[local.lcvs_name], {}),
    config_options        = try(var.config_options[local.lcvs_name], {}),
    replica_count         = var.resource_definitions[local.lcvs_name].replicas,
    resource_block        = var.resource_definitions[local.lcvs_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.lcvs_name].istio_proxy_resources,
  }), local.chart_files[local.lcvs_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.lcvs_name].istio_template, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.lcvs_name], null)
  }), local.chart_files[local.lcvs_name].istio_values_override])
}
