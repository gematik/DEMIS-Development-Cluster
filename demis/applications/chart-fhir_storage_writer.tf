locals {
  fssw_name = "fhir-storage-writer"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fssw_enabled = contains(local.service_names, local.fssw_name) ? var.deployment_information[local.fssw_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  fssw_template_app   = fileexists("${var.external_chart_path}/${local.fssw_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.fssw_name}/${local.application_values_file}" : "${path.module}/${local.fssw_name}/${local.application_values_file}"
  fssw_template_istio = fileexists("${var.external_chart_path}/${local.fssw_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.fssw_name}/${local.istio_values_file}" : "${path.module}/${local.fssw_name}/${local.istio_values_file}"
  # Define override for resources
  fssw_resources_overrides = try(var.resource_definitions[local.fssw_name], {})
  fssw_replicas            = lookup(local.fssw_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.fssw_name].replicas : null
  fssw_resource_block      = lookup(local.fssw_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.fssw_name].resource_block : null

  fssw_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.fssw_name}-database-secret"
    ),
    -1 # Default index if not found
  )

  fssw_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.fssw_name}-ddl-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "fhir_storage_writer" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fssw_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fssw_name
  deployment_information = var.deployment_information[local.fssw_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.fssw_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    feature_flags                                      = try(var.feature_flags[local.fssw_name], {}),
    config_options                                     = try(var.config_options[local.fssw_name], {}),
    replica_count                                      = local.fssw_replicas,
    resource_block                                     = local.fssw_resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.fssw_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.fssw_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    db_secret_checksum                                 = try(kubernetes_secret_v1.database_credentials[local.fssw_index].metadata[0].annotations["checksum"], ""),
    db_ddl_secret_checksum                             = try(kubernetes_secret_v1.database_credentials[local.fssw_ddl_index].metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.fssw_template_istio, {
    namespace                      = var.target_namespace,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.fssw_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
    http_timeout_retry_block       = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.fssw_name], null)
  })
}
