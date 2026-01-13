locals {
  bulk_inbound_name = "bulk-inbound-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  bulk_inbound_enabled = contains(local.service_names, local.bulk_inbound_name) ? var.deployment_information[local.bulk_inbound_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  bulk_inbound_template_app   = fileexists("${var.external_chart_path}/${local.bulk_inbound_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.bulk_inbound_name}/${local.application_values_file}" : "${path.module}/${local.bulk_inbound_name}/${local.application_values_file}"
  bulk_inbound_template_istio = fileexists("${var.external_chart_path}/${local.bulk_inbound_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.bulk_inbound_name}/${local.istio_values_file}" : "${path.module}/${local.bulk_inbound_name}/${local.istio_values_file}"
  # Define override for resources
  bulk_inbound_resources_overrides = try(var.resource_definitions[local.bulk_inbound_name], {})
  bulk_inbound_replicas            = lookup(local.bulk_inbound_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.bulk_inbound_name].replicas : null
  bulk_inbound_resource_block      = lookup(local.bulk_inbound_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.bulk_inbound_name].resource_block : null

  supported_ars_profile_versions = var.deployment_information["ars-profile-snapshots"].main.profiles
}

module "bulk_inbound_service" {
  source = "../../modules/helm_deployment"
  # Deploy if enabled
  count = local.bulk_inbound_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.bulk_inbound_name
  deployment_information = var.deployment_information[local.bulk_inbound_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.rabbitmq_service[0]]

  # Pass the values for the chart
  application_values = templatefile(local.bulk_inbound_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    core_hostname                                      = var.core_hostname,
    feature_flags                                      = try(var.feature_flags[local.bulk_inbound_name], {}),
    config_options                                     = try(var.config_options[local.bulk_inbound_name], {}),
    replica_count                                      = local.bulk_inbound_replicas,
    resource_block                                     = local.bulk_inbound_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.bulk_inbound_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.bulk_inbound_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.bulk_inbound_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    fhir_api_versions              = local.supported_ars_profile_versions,
    demis_hostnames                = local.demis_hostnames,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.bulk_inbound_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
  })
}
