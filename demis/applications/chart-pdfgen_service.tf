locals {
  pdfgen_name = "pdfgen-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  pdfgen_enabled = contains(local.service_names, local.pdfgen_name) ? var.deployment_information[local.pdfgen_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  pdfgen_template_app   = fileexists("${var.external_chart_path}/${local.pdfgen_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.pdfgen_name}/${local.application_values_file}" : "${path.module}/${local.pdfgen_name}/${local.application_values_file}"
  pdfgen_template_istio = fileexists("${var.external_chart_path}/${local.pdfgen_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.pdfgen_name}/${local.istio_values_file}" : "${path.module}/${local.pdfgen_name}/${local.istio_values_file}"
  # Define override for resources
  pdfgen_resources_overrides = try(var.resource_definitions[local.pdfgen_name], {})
  pdfgen_replicas            = lookup(local.pdfgen_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.pdfgen_name].replicas : null
  pdfgen_resource_block      = lookup(local.pdfgen_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.pdfgen_name].resource_block : null
}

module "pdfgen_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.pdfgen_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pdfgen_name
  deployment_information = var.deployment_information[local.pdfgen_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.pdfgen_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    feature_flags      = try(var.feature_flags[local.pdfgen_name], {}),
    config_options     = try(var.config_options[local.pdfgen_name], {}),
    replica_count      = local.pdfgen_replicas,
    resource_block     = local.pdfgen_resource_block
  })
  istio_values = templatefile(local.pdfgen_template_istio, {
    namespace = var.target_namespace
  })
}
