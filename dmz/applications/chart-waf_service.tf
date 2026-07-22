locals {
  waf_name = "waf-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  waf_enabled = contains(local.service_names, local.waf_name) ? var.deployment_information[local.waf_name].enabled : false
}

module "waf_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.waf_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.waf_name
  deployment_information = var.deployment_information[local.waf_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.secure_message_gateway[0], module.bulk_inbound_service[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.waf_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    core_hostname         = var.core_hostname,
    feature_flags         = try(var.feature_flags[local.waf_name], {}),
    config_options        = try(var.config_options[local.waf_name], {}),
    replica_count         = var.resource_definitions[local.waf_name].replicas,
    resource_block        = var.resource_definitions[local.waf_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.waf_name].istio_proxy_resources,
  }), local.chart_files[local.waf_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.waf_name].istio_template, {
    namespace                = var.target_namespace,
    context_path             = var.context_path,
    cluster_gateway          = var.cluster_gateway,
    demis_hostnames          = local.demis_hostnames,
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.waf_name], null)
  }), local.chart_files[local.waf_name].istio_values_override])
}
