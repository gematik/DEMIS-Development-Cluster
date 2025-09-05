locals {
  surveillance_programm_name  = "-ars"
  surveillance_pseudonym_name = "surveillance-pseudonym-service${local.surveillance_programm_name}"
  # Verify whether the service is defined or the deployment is explicitly enabled
  surveillance_pseudonym_enabled = contains(local.service_names, local.surveillance_pseudonym_name) ? var.deployment_information[local.surveillance_pseudonym_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  surveillance_pseudonym_template_app   = fileexists("${var.external_chart_path}/${local.surveillance_pseudonym_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.surveillance_pseudonym_name}/${local.application_values_file}" : "${path.module}/${local.surveillance_pseudonym_name}/${local.application_values_file}"
  surveillance_pseudonym_template_istio = fileexists("${var.external_chart_path}/${local.surveillance_pseudonym_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.surveillance_pseudonym_name}/${local.istio_values_file}" : "${path.module}/${local.surveillance_pseudonym_name}/${local.istio_values_file}"
  # Define override for resources
  surveillance_pseudonym_resources_overrides = try(var.resource_definitions[local.surveillance_pseudonym_name], {})
  surveillance_pseudonym_replicas            = lookup(local.surveillance_pseudonym_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.surveillance_pseudonym_name].replicas : null
  surveillance_pseudonym_resource_block      = lookup(local.surveillance_pseudonym_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.surveillance_pseudonym_name].resource_block : null
}

module "surveillance_pseudonym_service_ars" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.surveillance_pseudonym_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.surveillance_pseudonym_name
  deployment_information = var.deployment_information[local.surveillance_pseudonym_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.surveillance_pseudonym_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    core_hostname      = var.core_hostname,
    feature_flags      = try(var.feature_flags[local.surveillance_pseudonym_name], {}),
    config_options     = try(var.config_options[local.surveillance_pseudonym_name], {}),
    replica_count      = local.surveillance_pseudonym_replicas,
    resource_block     = local.surveillance_pseudonym_resource_block
  })
  istio_values = templatefile(local.surveillance_pseudonym_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    demis_hostnames = local.demis_hostnames
  })
}
