locals {
  are_nps_name = "are-notification-processing-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  service_enabled = contains(local.service_names, local.are_nps_name) ? var.deployment_information[local.are_nps_name].enabled : false
  # Define override for resources
  service_resources_overrides = try(var.resource_definitions[local.are_nps_name], {})
  service_replicas            = lookup(local.service_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.are_nps_name].replicas : null
  service_resource_block      = lookup(local.service_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.are_nps_name].resource_block : null
}

module "are_notification_processing_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.are_nps_name
  deployment_information = var.deployment_information[local.are_nps_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.are_nps_name].app_template, {
    namespace                             = var.target_namespace,
    image_pull_secrets                    = var.pull_secrets,
    repository                            = var.docker_registry,
    debug_enable                          = var.debug_enabled,
    istio_enable                          = var.istio_enabled,
    feature_flags                         = try(var.feature_flags[local.are_nps_name], {}),
    config_options                        = try(var.config_options[local.are_nps_name], {}),
    replica_count                         = local.service_replicas,
    resource_block                        = local.service_resource_block,
    istio_proxy_resources                 = try(local.service_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources),
    redis_user                            = var.redis_cus_reader_user,
    redis_cus_reader_credentials_checksum = try(kubernetes_secret_v1.redis_cus_reader_credentials.metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.are_nps_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.are_nps_name].istio_template, {
    namespace                  = var.target_namespace,
    cluster_gateway            = var.cluster_gateway,
    core_hostname              = var.core_hostname,
    context_path               = var.context_path,
    demis_hostnames            = local.demis_hostnames,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.are_nps_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.are_nps_name], [])
  }), local.chart_files[local.are_nps_name].istio_values_override])
}
