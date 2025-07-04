locals {
  ars_pseudonymization_name = "ars-pseudonymization-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  ars_pseudonymization_enabled = contains(local.service_names, local.ars_pseudonymization_name) ? var.deployment_information[local.ars_pseudonymization_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  ars_pseudonymization_template_app   = fileexists("${var.external_chart_path}/${local.ars_pseudonymization_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.ars_pseudonymization_name}/${local.application_values_file}" : "${path.module}/${local.ars_pseudonymization_name}/${local.application_values_file}"
  ars_pseudonymization_template_istio = fileexists("${var.external_chart_path}/${local.ars_pseudonymization_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.ars_pseudonymization_name}/${local.istio_values_file}" : "${path.module}/${local.ars_pseudonymization_name}/${local.istio_values_file}"
  # Define override for resources
  ars_pseudonymization_resources_overrides = try(var.resource_definitions[local.ars_pseudonymization_name], {})
  ars_pseudonymization_replicas            = lookup(local.ars_pseudonymization_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.ars_pseudonymization_name].replicas : null
  ars_pseudonymization_resource_block      = lookup(local.ars_pseudonymization_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.ars_pseudonymization_name].resource_block : null
}

module "ars_pseudonymization_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.ars_pseudonymization_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.ars_pseudonymization_name
  deployment_information = var.deployment_information[local.ars_pseudonymization_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.ars_pseudonymization_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    core_hostname      = var.core_hostname,
    feature_flags      = try(var.feature_flags[local.ars_pseudonymization_name], {}),
    config_options     = try(var.config_options[local.ars_pseudonymization_name], {}),
    replica_count      = local.ars_pseudonymization_replicas,
    resource_block     = local.ars_pseudonymization_resource_block
  })
  istio_values = templatefile(local.ars_pseudonymization_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    demis_hostnames = local.demis_hostnames
  })
}
