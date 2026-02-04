locals {
  dls_reader_name           = "destination-lookup-reader"
  dls_reader_information    = try(var.deployment_information[local.dls_reader_name], { enabled = false, main = { version = "" } })
  dls_reader_template_app   = fileexists("${var.external_chart_path}/${local.dls_reader_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_reader_name}/${local.application_values_file}" : "${path.module}/${local.dls_reader_name}/${local.application_values_file}"
  dls_reader_template_istio = fileexists("${var.external_chart_path}/${local.dls_reader_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_reader_name}/${local.istio_values_file}" : "${path.module}/${local.dls_reader_name}/${local.istio_values_file}"

  dlsr_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.dls_reader_name}-database-secret"
    ),
    -1 # Default index if not found
  )

  # Define override for resources
  dlsr_resources_overrides = try(var.resource_definitions[local.dls_reader_name], {})
  dlsr_replicas            = lookup(local.dlsr_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_reader_name].replicas : null
  dlsr_resource_block      = lookup(local.dlsr_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_reader_name].resource_block : null
}

module "destination_lookup_reader" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.dls_reader_information.enabled ? 1 : 0

  application_name       = local.dls_reader_name
  deployment_information = local.dls_reader_information
  helm_settings          = local.common_helm_release_settings
  namespace              = var.target_namespace
  depends_on             = [module.pgbouncer[0], module.destination_lookup_writer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.dls_reader_template_app, {
    app_name                                           = local.dls_reader_name,
    data_base                                          = replace(local.dls_name, "-", "_"),
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    feature_flags                                      = try(var.feature_flags[local.dls_reader_name], {}),
    config_options                                     = try(var.config_options[local.dls_reader_name], {}),
    resource_block                                     = local.dlsr_resource_block,
    replica_count                                      = local.dlsr_replicas,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.dls_reader_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.dlsr_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    db_secret_checksum                                 = try(kubernetes_secret_v1.database_credentials[local.dlsr_index].metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.dls_reader_template_istio, {
    namespace                = var.target_namespace,
    cluster_gateway          = var.cluster_gateway,
    context_path             = var.context_path,
    demis_hostnames          = local.demis_hostnames,
    app_name                 = local.dls_reader_name,
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.dls_reader_name], null)
  })
}
