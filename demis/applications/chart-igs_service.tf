locals {
  igs_name = "igs-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  igs_enabled = contains(local.service_names, local.igs_name) ? var.deployment_information[local.igs_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  igs_template_app   = fileexists("${var.external_chart_path}/${local.igs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.igs_name}/${local.application_values_file}" : "${path.module}/${local.igs_name}/${local.application_values_file}"
  igs_template_istio = fileexists("${var.external_chart_path}/${local.igs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.igs_name}/${local.istio_values_file}" : "${path.module}/${local.igs_name}/${local.istio_values_file}"
  # Define override for resources
  igs_resources_overrides = try(var.resource_definitions[local.igs_name], {})
  igs_replicas            = lookup(local.igs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.igs_name].replicas : null
  igs_resource_block      = lookup(local.igs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.igs_name].resource_block : null
}

module "igs_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.igs_name
  deployment_information = var.deployment_information[local.igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.minio[0]]

  # Pass the values for the chart
  application_values = templatefile(local.igs_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    debug_enable       = var.debug_enabled,
    istio_enable       = var.istio_enabled,
    core_hostname      = var.core_hostname,
    storage_hostname   = var.storage_hostname,
    s3_storage_url     = local.s3_storage_url,
    feature_flags      = try(var.feature_flags[local.igs_name], {}),
    config_options     = try(var.config_options[local.igs_name], {}),
    replica_count      = local.igs_replicas,
    resource_block     = local.igs_resource_block
  })
  istio_values = templatefile(local.igs_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    demis_hostnames                = local.demis_hostnames
    support_fhir_api_versions      = var.profile_provisioning_mode_vs_igs != null && var.profile_provisioning_mode_vs_igs != "dedicated"
    fhir_api_versions              = module.validation_service_igs_metadata.current_profile_versions,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.igs_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
