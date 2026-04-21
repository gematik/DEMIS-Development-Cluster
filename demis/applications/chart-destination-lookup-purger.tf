locals {
  dls_purger_name           = "destination-lookup-purger"
  dls_purger_information    = try(var.deployment_information[local.dls_purger_name], { enabled = false, main = { version = "" } })
  dls_purger_template_app   = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.application_values_file}" : "${path.module}/${local.dls_purger_name}/${local.application_values_file}"
  dls_purger_template_istio = fileexists("${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.dls_purger_name}/${local.istio_values_file}" : "${path.module}/${local.dls_purger_name}/${local.istio_values_file}"
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
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    suspend                                            = var.destination_lookup_purger_suspend,
    cron_schedule                                      = var.destination_lookup_purger_cron_schedule,
    feature_flags                                      = try(var.feature_flags[local.dls_purger_name], {}),
    config_options                                     = try(var.config_options[local.dls_purger_name], {}),
    replica_count                                      = var.resource_definitions[local.dls_purger_name].replicas,
    resource_block                                     = var.resource_definitions[local.dls_purger_name].resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.dls_purger_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false),
    istio_proxy_resources                              = var.resource_definitions[local.dls_purger_name].istio_proxy_resources,
  })
  istio_values = templatefile(local.dls_purger_template_istio, {
    namespace = var.target_namespace,
    app_name  = local.dls_purger_name
  })
}
