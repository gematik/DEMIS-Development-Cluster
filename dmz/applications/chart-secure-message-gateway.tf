locals {
  secure_message_gateway_name = "secure-message-gateway"
  # Verify whether the service is defined or the deployment is explicitly enabled
  secure_message_gateway_enabled = contains(local.service_names, local.secure_message_gateway_name) ? var.deployment_information[local.secure_message_gateway_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  secure_message_gateway_template_app   = fileexists("${var.external_chart_path}/${local.secure_message_gateway_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.secure_message_gateway_name}/${local.application_values_file}" : "${path.module}/${local.secure_message_gateway_name}/${local.application_values_file}"
  secure_message_gateway_template_istio = fileexists("${var.external_chart_path}/${local.secure_message_gateway_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.secure_message_gateway_name}/${local.istio_values_file}" : "${path.module}/${local.secure_message_gateway_name}/${local.istio_values_file}"
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
  application_values = templatefile(local.secure_message_gateway_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    feature_flags                                      = try(var.feature_flags[local.secure_message_gateway_name], {}),
    config_options                                     = try(var.config_options[local.secure_message_gateway_name], {}),
    replica_count                                      = var.resource_definitions[local.secure_message_gateway_name].replicas,
    resource_block                                     = var.resource_definitions[local.secure_message_gateway_name].resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.secure_message_gateway_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = var.resource_definitions[local.secure_message_gateway_name].istio_proxy_resources
    smg_secure_queue_encryption_secret_checksum        = try(kubernetes_secret_v1.ars_smg_secure_queue_encryption_secret.metadata[0].annotations["checksum"], ""),
  })
  istio_values = templatefile(local.secure_message_gateway_template_istio, {
    namespace                = var.target_namespace,
    context_path             = var.context_path,
    cluster_gateway          = var.cluster_gateway,
    demis_hostnames          = local.demis_hostnames,
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.secure_message_gateway_name], null)
  })
}