locals {
  ncapi_name = "notification-clearing-api"
  # Verify whether the service is defined or the deployment is explicitly enabled
  ncapi_enabled = contains(local.service_names, local.ncapi_name) ? var.deployment_information[local.ncapi_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  ncapi_template_app   = fileexists("${var.external_chart_path}/${local.ncapi_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.ncapi_name}/${local.application_values_file}" : "${path.module}/${local.ncapi_name}/${local.application_values_file}"
  ncapi_template_istio = fileexists("${var.external_chart_path}/${local.ncapi_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.ncapi_name}/${local.istio_values_file}" : "${path.module}/${local.ncapi_name}/${local.istio_values_file}"
  # Define override for resources
  ncapi_resources_overrides = try(var.resource_definitions[local.ncapi_name], {})
  ncapi_replicas            = lookup(local.ncapi_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.ncapi_name].replicas : null
  ncapi_resource_block      = lookup(local.ncapi_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.ncapi_name].resource_block : null
}

module "notification_clearing_api" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.ncapi_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.ncapi_name
  deployment_information = var.deployment_information[local.ncapi_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.ncapi_template_app, {
    image_pull_secrets         = var.pull_secrets,
    repository                 = var.docker_registry,
    namespace                  = var.target_namespace,
    debug_enable               = var.debug_enabled,
    istio_enable               = var.istio_enabled,
    core_hostname              = var.core_hostname,
    issuer_hostname            = var.auth_hostname,
    keycloak_internal_hostname = var.keycloak_internal_hostname,
    context_path               = var.context_path,
    feature_flags              = try(var.feature_flags[local.ncapi_name], {}),
    config_options             = try(var.config_options[local.ncapi_name], {}),
    replica_count              = local.ncapi_replicas,
    resource_block             = local.ncapi_resource_block,
  })
  istio_values = templatefile(local.ncapi_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    core_hostname   = var.core_hostname
  })
}
