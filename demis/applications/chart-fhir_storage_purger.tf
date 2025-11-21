locals {
  fsp_name = "fhir-storage-purger"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fsp_enabled = contains(local.service_names, local.fsp_name) ? var.deployment_information[local.fsp_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  fsp_template_app   = fileexists("${var.external_chart_path}/${local.fsp_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.fsp_name}/${local.application_values_file}" : "${path.module}/${local.fsp_name}/${local.application_values_file}"
  fsp_template_istio = fileexists("${var.external_chart_path}/${local.fsp_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.fsp_name}/${local.istio_values_file}" : "${path.module}/${local.fsp_name}/${local.istio_values_file}"
  # Define override for resources
  fsp_resources_overrides = try(var.resource_definitions[local.fsp_name], {})
  fsp_replicas            = lookup(local.fsp_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.fsp_name].replicas : null
  fsp_resource_block      = lookup(local.fsp_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.fsp_name].resource_block : null
}

module "fhir_storage_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fsp_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fsp_name
  deployment_information = var.deployment_information[local.fsp_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.fsp_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    suspend                                            = var.fhir_storage_purger_suspend,
    cron_schedule                                      = var.fhir_storage_purger_cron_schedule,
    feature_flags                                      = try(var.feature_flags[local.fsp_name], {}),
    config_options                                     = try(var.config_options[local.fsp_name], {}),
    replica_count                                      = local.fsp_replicas,
    resource_block                                     = local.fsp_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.fsp_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.fsp_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.fsp_template_istio, {
    namespace = var.target_namespace
  })
}
