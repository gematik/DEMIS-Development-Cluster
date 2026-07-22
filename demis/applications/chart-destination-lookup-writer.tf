locals {
  dls_name               = "destination-lookup"
  dls_writer_name        = "destination-lookup-writer"
  dls_writer_information = try(var.deployment_information[local.dls_writer_name], { enabled = false, main = { version = "" } })

  dlsw_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.dls_writer_name}-ddl-database-secret"
    ),
    -1 # Default index if not found
  )

  dlsw_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.dls_writer_name}-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "destination_lookup_writer" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.dls_writer_information.enabled ? 1 : 0

  application_name       = local.dls_writer_name
  deployment_information = local.dls_writer_information
  helm_settings          = local.common_helm_release_settings
  namespace              = var.target_namespace
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.dls_writer_name].app_template, {
    app_name               = local.dls_writer_name,
    data_base              = replace(local.dls_name, "-", "_"),
    image_pull_secrets     = var.pull_secrets,
    repository             = var.docker_registry,
    namespace              = var.target_namespace,
    debug_enable           = var.debug_enabled,
    feature_flags          = try(var.feature_flags[local.dls_writer_name], {}),
    config_options         = try(var.config_options[local.dls_writer_name], {}),
    resource_block         = var.resource_definitions[local.dls_writer_name].resource_block,
    replica_count          = var.resource_definitions[local.dls_writer_name].replicas,
    istio_proxy_resources  = var.resource_definitions[local.dls_writer_name].istio_proxy_resources,
    db_secret_checksum     = try(kubernetes_secret_v1.database_credentials[local.dlsw_index].metadata[0].annotations["checksum"], ""),
    db_ddl_secret_checksum = try(kubernetes_secret_v1.database_credentials[local.dlsw_ddl_index].metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.dls_writer_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.dls_writer_name].istio_template, {
    namespace                = var.target_namespace,
    app_name                 = local.dls_writer_name
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.dls_writer_name], null)
  }), local.chart_files[local.dls_writer_name].istio_values_override])
}
