locals {
  object_storage_service_name = "object-storage-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  object_storage_service_enabled = contains(local.service_names, local.object_storage_service_name) ? var.deployment_information[local.object_storage_service_name].enabled : false
}

module "object_storage_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.object_storage_service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.object_storage_service_name
  deployment_information = var.deployment_information[local.object_storage_service_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.object_storage_service_name].app_template, {
    image_pull_secrets                     = var.pull_secrets,
    repository                             = var.docker_registry,
    istio_enable                           = var.istio_enabled,
    feature_flags                          = try(var.feature_flags[local.object_storage_service_name], {}),
    config_options                         = try(var.config_options[local.object_storage_service_name], {}),
    replica_count                          = var.resource_definitions[local.object_storage_service_name].replicas,
    resource_block                         = var.resource_definitions[local.object_storage_service_name].resource_block,
    istio_proxy_resources                  = var.resource_definitions[local.object_storage_service_name].istio_proxy_resources,
    object_storage_service_secret_checksum = try(kubernetes_secret_v1.object_storage_service_credentials.metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.object_storage_service_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.object_storage_service_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    storage_hostname           = var.storage_hostname,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.object_storage_service_name], null),
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.object_storage_service_name], [])
  }), local.chart_files[local.object_storage_service_name].istio_values_override])
}
