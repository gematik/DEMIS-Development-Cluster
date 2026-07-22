locals {
  secure_message_gateway_name = "secure-message-gateway"
  # Verify whether the service is defined or the deployment is explicitly enabled
  secure_message_gateway_enabled = contains(local.service_names, local.secure_message_gateway_name) ? var.deployment_information[local.secure_message_gateway_name].enabled : false
}

module "secure_message_gateway" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.secure_message_gateway_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.secure_message_gateway_name
  deployment_information = var.deployment_information[local.secure_message_gateway_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.rabbitmq_service[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.secure_message_gateway_name].app_template, {
    image_pull_secrets                          = var.pull_secrets,
    repository                                  = var.docker_registry,
    namespace                                   = var.target_namespace,
    debug_enable                                = var.debug_enabled,
    istio_enable                                = var.istio_enabled,
    core_hostname                               = var.core_hostname,
    feature_flags                               = try(var.feature_flags[local.secure_message_gateway_name], {}),
    config_options                              = try(var.config_options[local.secure_message_gateway_name], {}),
    replica_count                               = var.resource_definitions[local.secure_message_gateway_name].replicas,
    resource_block                              = var.resource_definitions[local.secure_message_gateway_name].resource_block,
    istio_proxy_resources                       = var.resource_definitions[local.secure_message_gateway_name].istio_proxy_resources
    smg_secure_queue_encryption_secret_checksum = try(kubernetes_secret_v1.ars_smg_secure_queue_encryption_secret.metadata[0].annotations["checksum"], ""),
    smg_rabbitmq_credentials_checksum           = try(kubernetes_secret_v1.smg_rabbitmq_credentials.metadata[0].annotations["checksum"], ""),
  }), local.chart_files[local.secure_message_gateway_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.secure_message_gateway_name].istio_template, {
    namespace                = var.target_namespace,
    context_path             = var.context_path,
    cluster_gateway          = var.cluster_gateway,
    demis_hostnames          = local.demis_hostnames,
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.secure_message_gateway_name], null)
  }), local.chart_files[local.secure_message_gateway_name].istio_values_override])
}