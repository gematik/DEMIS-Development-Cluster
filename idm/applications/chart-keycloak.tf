locals {
  keycloak_name = "keycloak"
  # Verify whether the service is defined or the deployment is explicitly enabled
  keycloak_enabled = contains(local.service_names, local.keycloak_name) ? var.deployment_information[local.keycloak_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  keycloak_template_app   = fileexists("${var.external_chart_path}/${local.keycloak_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.keycloak_name}/${local.application_values_file}" : "${path.module}/${local.keycloak_name}/${local.application_values_file}"
  keycloak_template_istio = fileexists("${var.external_chart_path}/${local.keycloak_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.keycloak_name}/${local.istio_values_file}" : "${path.module}/${local.keycloak_name}/${local.istio_values_file}"
  # Define override for resources
  keycloak_resources_overrides = try(var.resource_definitions[local.keycloak_name], {})
  keycloak_replicas            = lookup(local.keycloak_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.keycloak_name].replicas : null
  keycloak_resource_block      = lookup(local.keycloak_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.keycloak_name].resource_block : null
}

module "keycloak" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.keycloak_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.keycloak_name
  deployment_information = var.deployment_information[local.keycloak_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.keycloak_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    istio_enable       = var.istio_enabled,
    local_stage        = var.is_local_mode,
    issuer_hostname    = local.auth_hostname,
    data_version       = var.stage_configuration_data_version,
    data_name          = var.stage_configuration_data_name,
    feature_flags      = try(var.feature_flags[local.keycloak_name], {}),
    config_options     = try(var.config_options[local.keycloak_name], {}),
    replica_count      = local.keycloak_replicas,
    resource_block     = local.keycloak_resource_block,
    enable_import      = var.keycloak_user_import_enabled
  })
  istio_values = templatefile(local.keycloak_template_istio, {
    namespace       = var.target_namespace,
    cluster_gateway = var.cluster_gateway,
    issuer_hostname = local.auth_hostname,
    core_hostname   = local.core_hostname
  })
}
