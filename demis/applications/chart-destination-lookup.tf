locals {
  dls_name                  = "destination-lookup"
  dls_writer_name           = "${local.dls_name}-writer"
  dls_writer_information    = try(var.deployment_information[local.dls_writer_name], { enabled = false, main = { version = "" } })
  dls_writer_template_app   = fileexists("${var.external_chart_path}/${local.dls_writer_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_writer_name}/${local.application_values_file}" : "${path.module}/${local.dls_writer_name}/${local.application_values_file}"
  dls_writer_template_istio = fileexists("${var.external_chart_path}/${local.dls_writer_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_writer_name}/${local.istio_values_file}" : "${path.module}/${local.dls_writer_name}/${local.istio_values_file}"

  # Define override for resources
  dlsw_resources_overrides = try(var.resource_definitions[local.dls_writer_name], {})
  dlsw_replicas            = lookup(local.dlsw_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_writer_name].replicas : null
  dlsw_resource_block      = lookup(local.dlsw_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_writer_name].resource_block : null

  dls_reader_name           = "${local.dls_name}-reader"
  dls_reader_information    = try(var.deployment_information[local.dls_reader_name], { enabled = false, main = { version = "" } })
  dls_reader_template_app   = fileexists("${var.external_chart_path}/${local.dls_reader_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_reader_name}/${local.application_values_file}" : "${path.module}/${local.dls_reader_name}/${local.application_values_file}"
  dls_reader_template_istio = fileexists("${var.external_chart_path}/${local.dls_reader_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_reader_name}/${local.istio_values_file}" : "${path.module}/${local.dls_reader_name}/${local.istio_values_file}"

  # Define override for resources
  dlsr_resources_overrides = try(var.resource_definitions[local.dls_reader_name], {})
  dlsr_replicas            = lookup(local.dlsr_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_reader_name].replicas : null
  dlsr_resource_block      = lookup(local.dlsr_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_reader_name].resource_block : null

  dls_purger_name           = "${local.dls_name}-purger"
  dls_purger_information    = try(var.deployment_information[local.dls_purger_name], { enabled = false, main = { version = "" } })
  dls_purger_template_app   = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}" : "${path.module}/${local.dls_purger_name}/${local.application_values_file}"
  dls_purger_template_istio = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}" : "${path.module}/${local.dls_purger_name}/${local.istio_values_file}"

  # Define override for resources
  dlsp_resources_overrides = try(var.resource_definitions[local.dls_purger_name], {})
  dlsp_replicas            = lookup(local.dlsp_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.dls_purger_name].replicas : null
  dlsp_resource_block      = lookup(local.dlsp_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.dls_purger_name].resource_block : null
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
    app_name           = local.dls_writer_name,
    data_base          = replace(local.dls_name, "-", "_"),
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    feature_flags      = try(var.feature_flags[local.dls_writer_name], {}),
    config_options     = try(var.config_options[local.dls_writer_name], {}),
    resource_block     = local.dlsw_resource_block,
    replica_count      = local.dlsw_replicas
  })
  istio_values = templatefile(local.dls_writer_template_istio, {
    namespace = var.target_namespace,
    app_name  = local.dls_writer_name
  })
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
    app_name           = local.dls_reader_name,
    data_base          = replace(local.dls_name, "-", "_"),
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    feature_flags      = try(var.feature_flags[local.dls_reader_name], {}),
    config_options     = try(var.config_options[local.dls_reader_name], {}),
    resource_block     = local.dlsr_resource_block,
    replica_count      = local.dlsr_replicas
  })
  istio_values = templatefile(local.dls_reader_template_istio, {
    namespace       = var.target_namespace,
    cluster_gateway = var.cluster_gateway,
    context_path    = var.context_path,
    demis_hostnames = local.demis_hostnames,
    app_name        = local.dls_reader_name
  })
}

module "destination_lookup_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.dls_purger_information.enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.dls_purger_name
  deployment_information = local.dls_purger_information
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.destination_lookup_writer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.dls_purger_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    suspend            = var.destination_lookup_purger_suspend,
    cron_schedule      = var.destination_lookup_purger_cron_schedule,
    feature_flags      = try(var.feature_flags[local.dls_purger_name], {}),
    config_options     = try(var.config_options[local.dls_purger_name], {}),
    replica_count      = local.dlsp_replicas,
    resource_block     = local.dlsp_resource_block
  })
  istio_values = templatefile(local.dls_purger_template_istio, {
    namespace = var.target_namespace,
    app_name  = local.dls_reader_name
  })
}
