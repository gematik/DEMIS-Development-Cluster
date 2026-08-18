# its the chart for the audit log service for fhir storage writer
locals {
  als_fssw_name = "audit-log-service-fssw"
  als_fssw_key  = "als-fssw"
  als_fssw_deployment_information = try(var.deployment_information[local.als_fssw_key], {
    enabled = false, main = { version = "" }
  })
}
module "audit_log_service_fssw" {
  source = "../../modules/helm_deployment"

  count                  = local.fssw_enabled && local.als_fssw_deployment_information.enabled ? 1 : 0
  namespace              = var.target_namespace
  application_name       = local.als_fssw_name
  deployment_information = local.als_fssw_deployment_information
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.fhir_storage_writer]

  application_values = [templatefile(local.chart_files[local.als_fssw_key].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    feature_flags         = try(var.feature_flags[local.als_fssw_key], {}),
    config_options        = try(var.config_options[local.als_fssw_key], {}),
    replica_count         = var.resource_definitions[local.als_fssw_key].replicas,
    resource_block        = var.resource_definitions[local.als_fssw_key].resource_block,
    istio_proxy_resources = var.resource_definitions[local.als_fssw_key].istio_proxy_resources
    app_name              = local.als_fssw_name
  }), local.chart_files[local.als_fssw_key].app_values_override]
  istio_values = compact([templatefile(local.chart_files[local.als_fssw_key].istio_template, {
    namespace = var.target_namespace,
    app_name  = local.als_fssw_name,
  }), local.chart_files[local.als_fssw_key].istio_values_override])
}
