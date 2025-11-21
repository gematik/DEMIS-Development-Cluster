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
  # FHIR Profile Snapshots
  fts_ars_profile_snapshots  = length(module.validation_service_ars_metadata.current_profile_versions) > 0 ? module.validation_service_ars_metadata.current_profile_versions : [local.ars_profile_snapshots]
  fts_fhir_profile_snapshots = length(module.validation_service_core_metadata.current_profile_versions) > 0 ? module.validation_service_core_metadata.current_profile_versions : [local.fhir_profile_snapshots]
  fts_igs_profile_snapshots  = length(module.validation_service_igs_metadata.current_profile_versions) > 0 ? module.validation_service_igs_metadata.current_profile_versions : [local.igs_profile_snapshots]
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
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_docker_registry                            = var.docker_registry,
    ars_profile_versions                               = local.fts_ars_profile_snapshots,
    fhir_profile_versions                              = local.fts_fhir_profile_snapshots,
    igs_profile_versions                               = local.fts_igs_profile_snapshots,
    feature_flags                                      = try(var.feature_flags[local.fts_name], {}),
    config_options                                     = try(var.config_options[local.fts_name], {}),
    replica_count                                      = local.fts_replicas,
    resource_block                                     = local.fts_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.fts_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.fts_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.fts_template_istio, {
    namespace = var.target_namespace
  })
}
