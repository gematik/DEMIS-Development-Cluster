locals {
  fts_name = "terminology-server"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fts_enabled = contains(local.service_names, local.fts_name) ? var.deployment_information[local.fts_name].enabled : false
  # FHIR Profile Snapshots
  fts_ars_profile_snapshots  = local.vs_ars_enabled ? module.validation_service_ars_apps[0].profile_metadata.current_profile_versions : []
  fts_fhir_profile_snapshots = []
  fts_igs_profile_snapshots  = local.vs_igs_enabled ? module.validation_service_igs_apps[0].profile_metadata.current_profile_versions : []
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
  application_values = compact([templatefile(local.chart_files[local.fts_name].app_template, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    namespace               = var.target_namespace,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
    ars_profile_versions    = local.fts_ars_profile_snapshots,
    fhir_profile_versions   = local.fts_fhir_profile_snapshots,
    igs_profile_versions    = local.fts_igs_profile_snapshots,
    feature_flags           = try(var.feature_flags[local.fts_name], {}),
    config_options          = try(var.config_options[local.fts_name], {}),
    replica_count           = var.resource_definitions[local.fts_name].replicas,
    resource_block          = var.resource_definitions[local.fts_name].resource_block,
    istio_proxy_resources   = var.resource_definitions[local.fts_name].istio_proxy_resources,
  }), local.chart_files[local.fts_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.fts_name].istio_template, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.fts_name], null)
  }), local.chart_files[local.fts_name].istio_values_override])
}
