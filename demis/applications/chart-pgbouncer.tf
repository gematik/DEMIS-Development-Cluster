locals {
  pgbouncer_name = "pgbouncer"
  # Verify whether the service is defined or the deployment is explicitly enabled
  pgbouncer_enabled = contains(local.service_names, local.pgbouncer_name) ? var.deployment_information[local.pgbouncer_name].enabled : false
}

module "pgbouncer" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.pgbouncer_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pgbouncer_name
  deployment_information = var.deployment_information[local.pgbouncer_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.postgres[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.pgbouncer_name].app_template, {
    image_pull_secrets                = var.pull_secrets,
    repository                        = var.docker_registry,
    database_host                     = var.database_target_host,
    istio_enable                      = var.istio_enabled,
    replica_count                     = var.resource_definitions[local.pgbouncer_name].replicas,
    resource_block                    = var.resource_definitions[local.pgbouncer_name].resource_block,
    config_options                    = try(var.config_options[local.pgbouncer_name], {}),
    pseudonymization_db_enabled       = local.pseudo_enabled
    fhir_storage_db_enabled           = local.fssw_enabled || local.fssr_enabled || local.fsp_enabled,
    surveillance_pseudonym_db_enabled = local.sps_db_enabled
    destination_lookup_db_enabled     = local.dls_reader_information.enabled || local.dls_writer_information.enabled || local.dls_purger_information.enabled,
    demis_bulk_stats_db_enabled       = local.ars_enabled
    userlist_secret_checksum          = try(kubernetes_secret_v1.pgbouncer_userlist.metadata[0].annotations["checksum"], ""),
    postgres_tls_secret_checksum      = try(kubernetes_secret_v1.postgresql_tls_certificates.metadata[0].annotations["checksum"], "")
    istio_proxy_resources             = var.resource_definitions[local.pgbouncer_name].istio_proxy_resources
  }), local.chart_files[local.pgbouncer_name].app_values_override])


  istio_values = compact([templatefile(local.chart_files[local.pgbouncer_name].istio_template, {
    namespace = var.target_namespace
  }), local.chart_files[local.pgbouncer_name].istio_values_override])
}
