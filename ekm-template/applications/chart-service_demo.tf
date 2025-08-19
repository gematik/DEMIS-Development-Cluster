locals {
  service_name = "service-demo"
  # Verify whether the service is defined or the deployment is explicitly enabled
  service_enabled = contains(local.service_names, local.service_name) ? var.deployment_information[local.service_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  service_template_app   = fileexists("${var.external_chart_path}/${local.service_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.service_name}/${local.application_values_file}" : "${path.module}/${local.service_name}/${local.application_values_file}"
  service_template_istio = fileexists("${var.external_chart_path}/${local.service_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.service_name}/${local.istio_values_file}" : "${path.module}/${local.service_name}/${local.istio_values_file}"
  # Define override for resources
  service_resources_overrides = try(var.resource_definitions[local.service_name], {})
  service_replicas            = lookup(local.service_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.service_name].replicas : null
  service_resource_block      = lookup(local.service_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.service_name].resource_block : null
}

module "service_demo" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.service_name
  deployment_information = var.deployment_information[local.service_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.service_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    feature_flags      = try(var.feature_flags[local.service_name], {}),
    config_options     = try(var.config_options[local.service_name], {}),
    replica_count      = local.service_replicas,
    resource_block     = local.service_resource_block
  })
  istio_values = templatefile(local.service_template_istio, {
    namespace       = var.target_namespace,
    cluster_gateway = var.cluster_gateway,
    context_path    = var.context_path,
    demis_hostnames = local.demis_hostnames
  })
}
