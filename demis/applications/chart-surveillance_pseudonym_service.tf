locals {
  ########################################
  # Surveilance Pseudonym Service - Base #
  ########################################
  sps_name       = "surveillance-pseudonym-service"
  sps_db_enabled = anytrue([for service in local.service_names : strcontains(service, local.sps_name)])

  ########################################
  # Surveilance Pseudonym Service - ARS  #
  ########################################
  sps_ars_name                = "${local.sps_name}-ars"
  sps_ars_enabled             = contains(local.service_names, local.sps_ars_name) ? var.deployment_information[local.sps_ars_name].enabled : false
  sps_ars_template_app        = fileexists("${var.external_chart_path}/${local.sps_ars_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.sps_ars_name}/${local.application_values_file}" : "${path.module}/${local.sps_ars_name}/${local.application_values_file}"
  sps_ars_template_istio      = fileexists("${var.external_chart_path}/${local.sps_ars_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.sps_ars_name}/${local.istio_values_file}" : "${path.module}/${local.sps_ars_name}/${local.istio_values_file}"
  sps_ars_resources_overrides = try(var.resource_definitions[local.sps_ars_name], {})
  sps_ars_replicas            = lookup(local.sps_ars_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.sps_ars_name].replicas : null
  sps_ars_resource_block      = lookup(local.sps_ars_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.sps_ars_name].resource_block : null

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
  application_values = templatefile(local.sps_ars_template_app, {
    image_pull_secrets              = var.pull_secrets,
    repository                      = var.docker_registry,
    namespace                       = var.target_namespace,
    debug_enable                    = var.debug_enabled,
    istio_enable                    = var.istio_enabled,
    core_hostname                   = var.core_hostname,
    feature_flags                   = try(var.feature_flags[local.sps_ars_name], {}),
    config_options                  = try(var.config_options[local.sps_ars_name], {}),
    replica_count                   = local.sps_ars_replicas,
    resource_block                  = local.sps_ars_resource_block,
    ars_pseudo_hash_pepper_checksum = try(kubernetes_secret.ars_pseudo_hash_pepper[0].metadata[0].annotations["checksum"], ""),
    sps_ars_db_secret_checksum      = try(kubernetes_secret.database_credentials[local.sps_ars_index].metadata[0].annotations["checksum"], ""),
    sps_ars_db_ddl_secret_checksum  = try(kubernetes_secret.database_credentials[local.sps_ars_ddl_index].metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.sps_ars_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    demis_hostnames = local.demis_hostnames
  })
}
