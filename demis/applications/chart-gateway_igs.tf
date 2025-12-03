locals {
  gateway_igs_name = "gateway-igs"
  # Verify whether the service is defined or the deployment is explicitly enabled
  gateway_igs_enabled = contains(local.service_names, local.gateway_igs_name) ? var.deployment_information[local.gateway_igs_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  gateway_igs_template_app   = fileexists("${var.external_chart_path}/${local.gateway_igs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.gateway_igs_name}/${local.application_values_file}" : "${path.module}/${local.gateway_igs_name}/${local.application_values_file}"
  gateway_igs_template_istio = fileexists("${var.external_chart_path}/${local.gateway_igs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.gateway_igs_name}/${local.istio_values_file}" : "${path.module}/${local.gateway_igs_name}/${local.istio_values_file}"
  # Define override for resources
  gateway_igs_resources_overrides = try(var.resource_definitions[local.gateway_igs_name], {})
  gateway_igs_replicas            = lookup(local.gateway_igs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.gateway_igs_name].replicas : null
  gateway_igs_resource_block      = lookup(local.gateway_igs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.gateway_igs_name].resource_block : null
}

module "gateway_igs" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.gateway_igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.gateway_igs_name
  deployment_information = var.deployment_information[local.gateway_igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.igs_service[0]]

  # Pass the values for the chart
  application_values = templatefile(local.gateway_igs_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    namespace                                          = var.target_namespace,
    feature_flags                                      = try(var.feature_flags[local.gateway_igs_name], {}),
    config_options                                     = try(var.config_options[local.gateway_igs_name], {}),
    replica_count                                      = local.gateway_igs_replicas,
    resource_block                                     = local.gateway_igs_resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.gateway_igs_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.gateway_igs_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    igs_profile_major_version                          = regex("^([0-9]+)", element(module.futs_igs_metadata.current_profile_versions, -1))[0],
    feature_flag_new_api_endpoints                     = try(var.feature_flags[local.gateway_igs_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
  istio_values = templatefile(local.gateway_igs_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    demis_hostnames = local.demis_hostnames
  })
}
