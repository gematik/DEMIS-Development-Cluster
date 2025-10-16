locals {
  lcvs_name = "lifecycle-validation-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  lcvs_enabled = contains(local.service_names, local.lcvs_name) ? var.deployment_information[local.lcvs_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  lcvs_template_app   = fileexists("${var.external_chart_path}/${local.lcvs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.lcvs_name}/${local.application_values_file}" : "${path.module}/${local.lcvs_name}/${local.application_values_file}"
  lcvs_template_istio = fileexists("${var.external_chart_path}/${local.lcvs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.lcvs_name}/${local.istio_values_file}" : "${path.module}/${local.lcvs_name}/${local.istio_values_file}"
  # Define override for resources
  lcvs_resources_overrides = try(var.resource_definitions[local.lcvs_name], {})
  lcvs_replicas            = lookup(local.lcvs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.lcvs_name].replicas : null
  lcvs_resource_block      = lookup(local.lcvs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.lcvs_name].resource_block : null
}

module "lifecycle_validation_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.lcvs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.lcvs_name
  deployment_information = var.deployment_information[local.lcvs_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.lcvs_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    feature_flags      = try(var.feature_flags[local.lcvs_name], {}),
    config_options     = try(var.config_options[local.lcvs_name], {}),
    replica_count      = local.lcvs_replicas,
    resource_block     = local.lcvs_resource_block
  })
  istio_values = templatefile(local.lcvs_template_istio, {
    namespace = var.target_namespace
  })
}
