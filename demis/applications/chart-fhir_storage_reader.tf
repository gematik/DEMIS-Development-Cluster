locals {
  fssr_name = "fhir-storage-reader"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fssr_enabled = contains(local.service_names, local.fssr_name) ? var.deployment_information[local.fssr_name].enabled : false

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
  depends_on             = [module.pgbouncer[0], module.fhir_storage_writer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.fssr_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    core_hostname         = var.core_hostname,
    context_path          = var.context_path,
    feature_flags         = try(var.feature_flags[local.fssr_name], {}),
    config_options        = try(var.config_options[local.fssr_name], {}),
    replica_count         = var.resource_definitions[local.fssr_name].replicas,
    resource_block        = var.resource_definitions[local.fssr_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.fssr_name].istio_proxy_resources,
    db_secret_checksum    = try(kubernetes_secret_v1.database_credentials[local.fssr_index].metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.fssr_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.fssr_name].istio_template, {
    namespace                  = var.target_namespace,
    cluster_gateway            = var.cluster_gateway,
    core_hostname              = var.core_hostname,
    context_path               = var.context_path,
    demis_hostnames            = local.demis_hostnames,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.fssr_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.fssr_name], [])
  }), local.chart_files[local.fssr_name].istio_values_override])
}
