locals {
  dls_reader_name        = "destination-lookup-reader"
  dls_reader_information = try(var.deployment_information[local.dls_reader_name], { enabled = false, main = { version = "" } })

  dlsr_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.dls_reader_name}-database-secret"
    ),
    -1 # Default index if not found
  )
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
  application_values = compact([templatefile(local.chart_files[local.dls_reader_name].app_template, {
    app_name              = local.dls_reader_name,
    data_base             = replace(local.dls_name, "-", "_"),
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    feature_flags         = try(var.feature_flags[local.dls_reader_name], {}),
    config_options        = try(var.config_options[local.dls_reader_name], {}),
    resource_block        = var.resource_definitions[local.dls_reader_name].resource_block,
    replica_count         = var.resource_definitions[local.dls_reader_name].replicas,
    istio_proxy_resources = var.resource_definitions[local.dls_reader_name].istio_proxy_resources,
    db_secret_checksum    = try(kubernetes_secret_v1.database_credentials[local.dlsr_index].metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.dls_reader_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.dls_reader_name].istio_template, {
    namespace                  = var.target_namespace,
    cluster_gateway            = var.cluster_gateway,
    context_path               = var.context_path,
    demis_hostnames            = local.demis_hostnames,
    app_name                   = local.dls_reader_name,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.dls_reader_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.dls_reader_name], [])
  }), local.chart_files[local.dls_reader_name].istio_values_override])
}
