locals {
  bundid_name = "bundid-idp"
  # Verify whether the service is defined or the deployment is explicitly enabled
  bundid_enabled = contains(local.service_names, local.bundid_name) ? var.deployment_information[local.bundid_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  bundid_template_app   = fileexists("${var.external_chart_path}/${local.bundid_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.bundid_name}/${local.application_values_file}" : "${path.module}/${local.bundid_name}/${local.application_values_file}"
  bundid_template_istio = fileexists("${var.external_chart_path}/${local.bundid_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.bundid_name}/${local.istio_values_file}" : "${path.module}/${local.bundid_name}/${local.istio_values_file}"
  # Define override for resources
  bundid_resources_overrides = try(var.resource_definitions[local.bundid_name], {})
  bundid_replicas            = lookup(local.bundid_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.bundid_name].replicas : null
  bundid_resource_block      = lookup(local.bundid_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.bundid_name].resource_block : null
}

module "bundid_idp" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.bundid_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.bundid_name
  deployment_information = var.deployment_information[local.bundid_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.bundid_template_app, {
    image_pull_secrets = var.pull_secrets,
    repository         = var.docker_registry,
    namespace          = var.target_namespace,
    istio_enable       = var.istio_enabled,
    issuer_hostname    = local.bundid_idp_hostname,
    data_version       = local.stage_configuration_data_version,
    data_name          = local.stage_configuration_data_name,
    feature_flags      = try(var.feature_flags[local.bundid_name], {}),
    config_options     = try(var.config_options[local.bundid_name], {}),
    replica_count      = local.bundid_replicas,
    resource_block     = local.bundid_resource_block,
    enable_import      = var.bundid_idp_user_import_enabled
  })
  istio_values = templatefile(local.bundid_template_istio, {
    namespace       = var.target_namespace,
    cluster_gateway = var.cluster_gateway,
    issuer_hostname = local.bundid_idp_hostname
  })
}
