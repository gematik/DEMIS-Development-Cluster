locals {
  postgres_name = "postgres"
  # Verify whether the service is defined or the deployment is explicitly enabled
  postgres_enabled = contains(local.service_names, local.postgres_name) ? var.deployment_information[local.postgres_name].enabled : false

  postgres_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.postgres_name}-secret"
    ),
    -1 # Default index if not found
  )

}

module "postgres" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.postgres_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.postgres_name
  deployment_information = var.deployment_information[local.postgres_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.postgres_name].app_template, {
    image_pull_secrets           = var.pull_secrets,
    repository                   = var.docker_registry,
    istio_enable                 = var.istio_enabled,
    debug_enable                 = var.debug_enabled,
    feature_flags                = try(var.feature_flags[local.postgres_name], {}),
    config_options               = try(var.config_options[local.postgres_name], {}),
    replica_count                = var.resource_definitions[local.postgres_name].replicas,
    resource_block               = var.resource_definitions[local.postgres_name].resource_block,
    demis_bulk_db_enabled        = local.bulk_inbound_enabled
    postgres_tls_secret_checksum = try(kubernetes_secret_v1.postgresql_tls_certificates.metadata[0].annotations["checksum"], ""),
    db_secret_checksum           = try(kubernetes_secret_v1.database_credentials[local.postgres_index].metadata[0].annotations["checksum"], "")
    istio_proxy_resources        = var.resource_definitions[local.postgres_name].istio_proxy_resources,
  }), local.chart_files[local.postgres_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.postgres_name].istio_template, {
    namespace = var.target_namespace
  }), local.chart_files[local.postgres_name].istio_values_override])
}
