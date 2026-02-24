locals {
  rabbitmq_name = "rabbitmq"
  # Verify whether the service is defined or the deployment is explicitly enabled
  rabbitmq_enabled = contains(local.service_names, local.rabbitmq_name) ? var.deployment_information[local.rabbitmq_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  rabbitmq_template_app   = fileexists("${var.external_chart_path}/${local.rabbitmq_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.rabbitmq_name}/${local.application_values_file}" : "${path.module}/${local.rabbitmq_name}/${local.application_values_file}"
  rabbitmq_template_istio = fileexists("${var.external_chart_path}/${local.rabbitmq_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.rabbitmq_name}/${local.istio_values_file}" : "${path.module}/${local.rabbitmq_name}/${local.istio_values_file}"
  # Define override for resources
  rabbitmq_resources_overrides = try(var.resource_definitions[local.rabbitmq_name], {})
  rabbitmq_replicas            = lookup(local.rabbitmq_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.rabbitmq_name].replicas : null
  rabbitmq_replicas_is_even    = local.rabbitmq_replicas != null ? local.rabbitmq_replicas % 2 == 0 : false
  rabbitmq_resource_block      = lookup(local.rabbitmq_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.rabbitmq_name].resource_block : null
}

resource "null_resource" "check_odd_replicas" {
  count = local.rabbitmq_enabled && local.rabbitmq_replicas_is_even && !var.allow_even_rabbitmq_replicas ? 1 : 0
  lifecycle {
    postcondition {
      condition     = !local.rabbitmq_replicas_is_even || var.allow_even_rabbitmq_replicas
      error_message = "RabbitMQ replicas are even (${local.rabbitmq_replicas}); odd replica count is recommended for high availability. To allow even replicas, set allow_even_rabbitmq_replicas = true."
    }
  }
}

module "rabbitmq_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.rabbitmq_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.rabbitmq_name
  deployment_information = var.deployment_information[local.rabbitmq_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.rabbitmq_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    feature_flags                                      = try(var.feature_flags[local.rabbitmq_name], {}),
    config_options                                     = try(var.config_options[local.rabbitmq_name], {}),
    replica_count                                      = local.rabbitmq_replicas,
    resource_block                                     = local.rabbitmq_resource_block
    storage_class                                      = var.rabbitmq_pvc_config.storageClass,
    volume_capacity                                    = var.rabbitmq_pvc_config.capacity,
    access_modes                                       = var.rabbitmq_pvc_config.accessModes
    rabbitmq_password_hash                             = var.rabbitmq_password_hash,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.rabbitmq_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.rabbitmq_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.rabbitmq_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    demis_hostnames = local.demis_hostnames
  })
}
