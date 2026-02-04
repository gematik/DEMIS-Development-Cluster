locals {
  ars_name = "ars-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  ars_enabled = contains(local.service_names, local.ars_name) ? var.deployment_information[local.ars_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  ars_template_app   = fileexists("${var.external_chart_path}/${local.ars_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.ars_name}/${local.application_values_file}" : "${path.module}/${local.ars_name}/${local.application_values_file}"
  ars_template_istio = fileexists("${var.external_chart_path}/${local.ars_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.ars_name}/${local.istio_values_file}" : "${path.module}/${local.ars_name}/${local.istio_values_file}"
  # Define override for resources
  ars_resources_overrides = try(var.resource_definitions[local.ars_name], {})
  ars_replicas            = lookup(local.ars_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.ars_name].replicas : null
  ars_resource_block      = lookup(local.ars_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.ars_name].resource_block : null

  ars_bulk_stats_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-bulk-stats-ddl-database-secret"
    ),
    -1 # Default index if not found
  )

  ars_bulk_stats_user_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-bulk-stats-user-database-secret"
    ),
    -1 # Default index if not found
  )

  ars_bulk_stats_purger_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-bulk-stats-purger-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "ars_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.ars_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.ars_name
  deployment_information = var.deployment_information[local.ars_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.ars_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    feature_flags                                      = try(var.feature_flags[local.ars_name], {}),
    config_options                                     = try(var.config_options[local.ars_name], {}),
    replica_count                                      = local.ars_replicas,
    resource_block                                     = local.ars_resource_block
    ars_bulk_stats_ddl_db_secret_checksum              = try(kubernetes_secret_v1.database_credentials[local.ars_bulk_stats_ddl_index].metadata[0].annotations["checksum"], ""),
    ars_bulk_stats_user_db_secret_checksum             = try(kubernetes_secret_v1.database_credentials[local.ars_bulk_stats_user_index].metadata[0].annotations["checksum"], ""),
    ars_bulk_stats_purger_db_secret_checksum           = try(kubernetes_secret_v1.database_credentials[local.ars_bulk_stats_purger_index].metadata[0].annotations["checksum"], ""),
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.ars_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.ars_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.ars_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    demis_hostnames                = local.demis_hostnames
    support_fhir_api_versions      = var.profile_provisioning_mode_vs_ars != null && var.profile_provisioning_mode_vs_ars != "dedicated"
    fhir_api_versions              = module.validation_service_ars_metadata.current_profile_versions,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.ars_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
    http_timeout_retry_block       = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.ars_name], null)
  })
}
