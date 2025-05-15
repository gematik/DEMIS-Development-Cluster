locals {
  pss_name = "pseudonymization-storage-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  pss_enabled = contains(local.service_names, local.pss_name) ? var.deployment_information[local.pss_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  pss_template_app   = fileexists("${var.external_chart_path}/${local.pss_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.pss_name}/${local.application_values_file}" : "${path.module}/${local.pss_name}/${local.application_values_file}"
  pss_template_istio = fileexists("${var.external_chart_path}/${local.pss_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.pss_name}/${local.istio_values_file}" : "${path.module}/${local.pss_name}/${local.istio_values_file}"
  # Define override for resources
  pss_resources_overrides = try(var.resource_definitions[local.pss_name], {})
  pss_replicas            = lookup(local.pss_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.pss_name].replicas : null
  pss_resource_block      = lookup(local.pss_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.pss_name].resource_block : null
}

module "pseudonymization_storage_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.pss_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pss_name
  deployment_information = var.deployment_information[local.pss_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.pss_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    feature_flags      = try(var.feature_flags[local.pss_name], {}),
    config_options     = try(var.config_options[local.pss_name], {}),
    replica_count      = local.pss_replicas,
    resource_block     = local.pss_resource_block
  })
  istio_values = templatefile(local.pss_template_istio, {
    namespace = var.target_namespace
  })
}
