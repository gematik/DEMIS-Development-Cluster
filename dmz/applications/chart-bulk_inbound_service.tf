locals {
  bulk_inbound_name = "bulk-inbound-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  bulk_inbound_enabled = contains(local.service_names, local.bulk_inbound_name) ? var.deployment_information[local.bulk_inbound_name].enabled : false

  ars_bulk_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-bulk-ddl-database-secret"
    ),
    -1 # Default index if not found
  )

  ars_bulk_user_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-bulk-user-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "bulk_inbound_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.bulk_inbound_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.bulk_inbound_name
  deployment_information = var.deployment_information[local.bulk_inbound_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.rabbitmq_service[0], module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.bulk_inbound_name].app_template, {
    image_pull_secrets                      = var.pull_secrets,
    repository                              = var.docker_registry,
    namespace                               = var.target_namespace,
    debug_enable                            = var.debug_enabled,
    istio_enable                            = var.istio_enabled,
    core_hostname                           = var.core_hostname,
    context_path                            = var.context_path,
    feature_flags                           = try(var.feature_flags[local.bulk_inbound_name], {}),
    config_options                          = try(var.config_options[local.bulk_inbound_name], {}),
    replica_count                           = var.resource_definitions[local.bulk_inbound_name].replicas,
    resource_block                          = var.resource_definitions[local.bulk_inbound_name].resource_block,
    ars_bulk_ddl_db_secret_checksum         = try(kubernetes_secret_v1.database_credentials[local.ars_bulk_ddl_index].metadata[0].annotations["checksum"], ""),
    ars_bulk_user_db_secret_checksum        = try(kubernetes_secret_v1.database_credentials[local.ars_bulk_user_index].metadata[0].annotations["checksum"], ""),
    ars_bulk_upload_hmac_secret_checksum    = try(var.ars_bulk_upload_hmac_secret.metadata[0].annotations["checksum"], ""),
    bulk_inbound_encryption_secret_checksum = try(kubernetes_secret_v1.ars_bis_in_queue_encryption_secret.metadata[0].annotations["checksum"], ""),
    bis_rabbitmq_credentials_checksum       = try(kubernetes_secret_v1.bis_rabbitmq_credentials.metadata[0].annotations["checksum"], ""),
    istio_proxy_resources                   = var.resource_definitions[local.bulk_inbound_name].istio_proxy_resources,
  }), local.chart_files[local.bulk_inbound_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.bulk_inbound_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    demis_hostnames            = local.demis_hostnames,
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.bulk_inbound_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.bulk_inbound_name], [])
  }), local.chart_files[local.bulk_inbound_name].istio_values_override])
}
