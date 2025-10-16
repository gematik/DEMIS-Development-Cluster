locals {
  dls_name                  = "destination-lookup"
  dls_writer_name           = "destination-lookup-writer"
  dls_writer_information    = try(var.deployment_information[local.dls_writer_name], { enabled = false, main = { version = "" } })
  dls_writer_template_app   = fileexists("${var.external_chart_path}/${local.dls_writer_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_writer_name}/${local.application_values_file}" : "${path.module}/${local.dls_writer_name}/${local.application_values_file}"
  dls_writer_template_istio = fileexists("${var.external_chart_path}/${local.dls_writer_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_writer_name}/${local.istio_values_file}" : "${path.module}/${local.dls_writer_name}/${local.istio_values_file}"

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

  # Define override for resources
  dlsw_resources_overrides = try(var.resource_definitions[local.dls_writer_name], {})
  dlsw_replicas            = lookup(local.dlsw_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_writer_name].replicas : null
  dlsw_resource_block      = lookup(local.dlsw_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_writer_name].resource_block : null
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
  application_values = templatefile(local.dls_writer_template_app, {
    app_name               = local.dls_writer_name,
    data_base              = replace(local.dls_name, "-", "_"),
    image_pull_secrets     = var.pull_secrets,
    repository             = var.docker_registry,
    namespace              = var.target_namespace,
    debug_enable           = var.debug_enabled,
    feature_flags          = try(var.feature_flags[local.dls_writer_name], {}),
    config_options         = try(var.config_options[local.dls_writer_name], {}),
    resource_block         = local.dlsw_resource_block,
    replica_count          = local.dlsw_replicas,
    db_secret_checksum     = try(kubernetes_secret.database_credentials[local.dlsw_index].metadata[0].annotations["checksum"], ""),
    db_ddl_secret_checksum = try(kubernetes_secret.database_credentials[local.dlsw_ddl_index].metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.dls_writer_template_istio, {
    namespace = var.target_namespace,
    app_name  = local.dls_writer_name
  })
}

