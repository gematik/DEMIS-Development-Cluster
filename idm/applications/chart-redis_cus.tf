locals {
  rediscus_name = "redis-cus"
  # Verify whether the service is defined or the deployment is explicitly enabled
  rediscus_enabled = contains(local.service_names, local.rediscus_name) ? var.deployment_information[local.rediscus_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  rediscus_template_app   = fileexists("${var.external_chart_path}/${local.rediscus_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.rediscus_name}/${local.application_values_file}" : "${path.module}/${local.rediscus_name}/${local.application_values_file}"
  rediscus_template_istio = fileexists("${var.external_chart_path}/${local.rediscus_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.rediscus_name}/${local.istio_values_file}" : "${path.module}/${local.rediscus_name}/${local.istio_values_file}"
  # Define override for resources
  rediscus_resources_overrides = try(var.resource_definitions[local.rediscus_name], {})
  rediscus_replicas            = lookup(local.rediscus_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.rediscus_name].replicas : null
  rediscus_resource_block      = lookup(local.rediscus_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.rediscus_name].resource_block : null
}

module "redis_cus" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.rediscus_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.rediscus_name
  deployment_information = var.deployment_information[local.rediscus_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.rediscus_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    istio_enable       = var.istio_enabled,
    replica_count      = local.rediscus_replicas,
    resource_block     = local.rediscus_resource_block
  })
  istio_values = templatefile(local.rediscus_template_istio, {
    namespace = var.target_namespace
  })
}
