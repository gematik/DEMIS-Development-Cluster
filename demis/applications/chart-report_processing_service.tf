locals {
  rps_name = "report-processing-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  rps_enabled = contains(local.service_names, local.rps_name) ? var.deployment_information[local.rps_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  rps_template_app   = fileexists("${var.external_chart_path}/${local.rps_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.rps_name}/${local.application_values_file}" : "${path.module}/${local.rps_name}/${local.application_values_file}"
  rps_template_istio = fileexists("${var.external_chart_path}/${local.rps_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.rps_name}/${local.istio_values_file}" : "${path.module}/${local.rps_name}/${local.istio_values_file}"
  # Define override for resources
  rps_resources_overrides = try(var.resource_definitions[local.rps_name], {})
  rps_replicas            = lookup(local.rps_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.rps_name].replicas : null
  rps_resource_block      = lookup(local.rps_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.rps_name].resource_block : null
}

module "report_processing_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.rps_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.rps_name
  deployment_information = var.deployment_information[local.rps_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.rps_template_app, {
    image_pull_secrets         = var.pull_secrets,
    repository                 = var.docker_registry,
    namespace                  = var.target_namespace,
    debug_enable               = var.debug_enabled,
    istio_enable               = var.istio_enabled,
    keycloak_internal_hostname = var.keycloak_internal_hostname,
    feature_flags              = try(var.feature_flags[local.rps_name], {}),
    config_options             = try(var.config_options[local.rps_name], {}),
    replica_count              = local.rps_replicas,
    resource_block             = local.rps_resource_block
  })
  istio_values = templatefile(local.rps_template_istio, {
    namespace       = var.target_namespace,
    context_path    = var.context_path,
    cluster_gateway = var.cluster_gateway,
    core_hostname   = var.core_hostname
  })
}
