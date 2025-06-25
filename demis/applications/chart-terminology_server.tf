locals {
  fts_name = "terminology-server"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fts_enabled = contains(local.service_names, local.fts_name) ? var.deployment_information[local.fts_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  fts_template_app   = fileexists("${var.external_chart_path}/${local.fts_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.fts_name}/${local.application_values_file}" : "${path.module}/${local.fts_name}/${local.application_values_file}"
  fts_template_istio = fileexists("${var.external_chart_path}/${local.fts_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.fts_name}/${local.istio_values_file}" : "${path.module}/${local.fts_name}/${local.istio_values_file}"
  # Define override for resources
  fts_resources_overrides = try(var.resource_definitions[local.fts_name], {})
  fts_replicas            = lookup(local.fts_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.fts_name].replicas : null
  fts_resource_block      = lookup(local.fts_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.fts_name].resource_block : null
}

module "terminology_server" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fts_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fts_name
  deployment_information = var.deployment_information[local.fts_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.fts_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    namespace               = var.target_namespace,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
    ars_profile_version     = local.ars_profile_snapshots,
    fhir_profile_version    = local.fhir_profile_snapshots,
    igs_profile_version     = local.igs_profile_snapshots,
    feature_flags           = try(var.feature_flags[local.fts_name], {}),
    config_options          = try(var.config_options[local.fts_name], {}),
    replica_count           = local.fts_replicas,
    resource_block          = local.fts_resource_block
  })
  istio_values = templatefile(local.fts_template_istio, {
    namespace = var.target_namespace
  })
}
