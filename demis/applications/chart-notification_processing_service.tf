locals {
  nps_name = "notification-processing-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  nps_enabled = contains(local.service_names, local.nps_name) ? var.deployment_information[local.nps_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  nps_template_app   = fileexists("${var.external_chart_path}/${local.nps_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.nps_name}/${local.application_values_file}" : "${path.module}/${local.nps_name}/${local.application_values_file}"
  nps_template_istio = fileexists("${var.external_chart_path}/${local.nps_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.nps_name}/${local.istio_values_file}" : "${path.module}/${local.nps_name}/${local.istio_values_file}"
  # Define override for resources
  nps_resources_overrides = try(var.resource_definitions[local.nps_name], {})
  nps_replicas            = lookup(local.nps_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.nps_name].replicas : null
  nps_resource_block      = lookup(local.nps_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.nps_name].resource_block : null
}

module "notification_processing_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.nps_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.nps_name
  deployment_information = var.deployment_information[local.nps_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.nps_template_app, {
    image_pull_secrets                    = var.pull_secrets,
    repository                            = var.docker_registry,
    namespace                             = var.target_namespace,
    debug_enable                          = var.debug_enabled,
    istio_enable                          = var.istio_enabled,
    redis_user                            = var.redis_cus_reader_user,
    feature_flags                         = try(var.feature_flags[local.nps_name], {}),
    config_options                        = try(var.config_options[local.nps_name], {}),
    replica_count                         = local.nps_replicas,
    resource_block                        = local.nps_resource_block,
    redis_cus_reader_credentials_checksum = try(kubernetes_secret.redis_cus_reader_credentials.metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.nps_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    core_hostname                  = var.core_hostname
    support_fhir_api_versions      = var.profile_provisioning_mode_vs_core != null && var.profile_provisioning_mode_vs_core != "dedicated"
    fhir_api_versions              = module.validation_service_core_metadata.current_profile_versions,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.nps_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
