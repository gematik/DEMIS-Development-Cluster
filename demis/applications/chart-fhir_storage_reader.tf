locals {
  fssr_name = "fhir-storage-reader"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fssr_enabled = contains(local.service_names, local.fssr_name) ? var.deployment_information[local.fssr_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  fssr_template_app   = fileexists("${var.external_chart_path}/${local.fssr_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.fssr_name}/${local.application_values_file}" : "${path.module}/${local.fssr_name}/${local.application_values_file}"
  fssr_template_istio = fileexists("${var.external_chart_path}/${local.fssr_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.fssr_name}/${local.istio_values_file}" : "${path.module}/${local.fssr_name}/${local.istio_values_file}"
  # Define override for resources
  fssr_resources_overrides = try(var.resource_definitions[local.fssr_name], {})
  fssr_replicas            = lookup(local.fssr_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.fssr_name].replicas : null
  fssr_resource_block      = lookup(local.fssr_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.fssr_name].resource_block : null

  fssr_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.fssr_name}-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "fhir_storage_reader" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fssr_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fssr_name
  deployment_information = var.deployment_information[local.fssr_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.fssr_template_app, {
    image_pull_secrets             = var.pull_secrets,
    repository                     = var.docker_registry,
    namespace                      = var.target_namespace,
    debug_enable                   = var.debug_enabled,
    istio_enable                   = var.istio_enabled,
    core_hostname                  = var.core_hostname,
    context_path                   = var.context_path,
    feature_flags                  = try(var.feature_flags[local.fssr_name], {}),
    config_options                 = try(var.config_options[local.fssr_name], {}),
    replica_count                  = local.fssr_replicas,
    resource_block                 = local.fssr_resource_block,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.fssr_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false),
    db_secret_checksum             = try(kubernetes_secret.database_credentials[local.fssr_index].metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.fssr_template_istio, {
    namespace                      = var.target_namespace,
    cluster_gateway                = var.cluster_gateway,
    core_hostname                  = var.core_hostname,
    context_path                   = var.context_path,
    demis_hostnames                = local.demis_hostnames,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.fssr_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}

