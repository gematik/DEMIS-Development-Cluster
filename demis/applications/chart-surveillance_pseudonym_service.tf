locals {
  ########################################
  # Surveilance Pseudonym Service - Base #
  ########################################
  sps_name       = "surveillance-pseudonym-service"
  sps_db_enabled = anytrue([for service in local.service_names : strcontains(service, local.sps_name)])

  ########################################
  # Surveilance Pseudonym Service - ARS  #
  ########################################
  sps_ars_name    = "${local.sps_name}-ars"
  sps_ars_enabled = contains(local.service_names, local.sps_ars_name) ? var.deployment_information[local.sps_ars_name].enabled : false

  sps_ars_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-pseudo-user-database-secret"
    ),
    -1 # Default index if not found
  )

  sps_ars_ddl_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "ars-pseudo-ddl-database-secret"
    ),
    -1 # Default index if not found
  )
}


########################################
# Surveilance Pseudonym Service - ARS  #
########################################

module "surveillance_pseudonym_service_ars" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.sps_ars_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.sps_ars_name
  deployment_information = var.deployment_information[local.sps_ars_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.sps_ars_name].app_template, {
    image_pull_secrets              = var.pull_secrets,
    repository                      = var.docker_registry,
    namespace                       = var.target_namespace,
    debug_enable                    = var.debug_enabled,
    istio_enable                    = var.istio_enabled,
    core_hostname                   = var.core_hostname,
    feature_flags                   = try(var.feature_flags[local.sps_ars_name], {}),
    config_options                  = try(var.config_options[local.sps_ars_name], {}),
    replica_count                   = var.resource_definitions[local.sps_ars_name].replicas,
    resource_block                  = var.resource_definitions[local.sps_ars_name].resource_block,
    ars_pseudo_hash_pepper_checksum = try(kubernetes_secret_v1.ars_pseudo_hash_pepper[0].metadata[0].annotations["checksum"], ""),
    sps_ars_db_secret_checksum      = try(kubernetes_secret_v1.database_credentials[local.sps_ars_index].metadata[0].annotations["checksum"], ""),
    sps_ars_db_ddl_secret_checksum  = try(kubernetes_secret_v1.database_credentials[local.sps_ars_ddl_index].metadata[0].annotations["checksum"], "")
    istio_proxy_resources           = var.resource_definitions[local.sps_ars_name].istio_proxy_resources,
  }), local.chart_files[local.sps_ars_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.sps_ars_name].istio_template, {
    namespace                = var.target_namespace,
    context_path             = var.context_path,
    cluster_gateway          = var.cluster_gateway,
    demis_hostnames          = local.demis_hostnames
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.sps_ars_name], null)
  }), local.chart_files[local.sps_ars_name].istio_values_override])
}
