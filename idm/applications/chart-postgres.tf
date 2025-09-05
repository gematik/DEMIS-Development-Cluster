locals {
  postgres_name = "postgres"
  # Verify whether the service is defined or the deployment is explicitly enabled
  postgres_enabled = contains(local.service_names, local.postgres_name) ? var.deployment_information[local.postgres_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  postgres_template_app   = fileexists("${var.external_chart_path}/${local.postgres_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.postgres_name}/${local.application_values_file}" : "${path.module}/${local.postgres_name}/${local.application_values_file}"
  postgres_template_istio = fileexists("${var.external_chart_path}/${local.postgres_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.postgres_name}/${local.istio_values_file}" : "${path.module}/${local.postgres_name}/${local.istio_values_file}"
  # Define override for resources
  postgres_resources_overrides = try(var.resource_definitions[local.postgres_name], {})
  postgres_replicas            = lookup(local.postgres_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.postgres_name].replicas : null
  postgres_resource_block      = lookup(local.postgres_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.postgres_name].resource_block : null
}

module "postgres" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.postgres_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.postgres_name
  deployment_information = var.deployment_information[local.postgres_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.postgres_template_app, {
    image_pull_secrets  = var.pull_secrets,
    repository          = var.docker_registry,
    istio_enable        = var.istio_enabled,
    debug_enable        = var.debug_enabled,
    feature_flags       = try(var.feature_flags[local.postgres_name], {}),
    config_options      = try(var.config_options[local.postgres_name], {}),
    replica_count       = local.postgres_replicas,
    resource_block      = local.postgres_resource_block
    keycloak_db_enabled = local.keycloak_enabled
    bundid_db_enabled   = local.bundid_enabled
  })
  istio_values = templatefile(local.postgres_template_istio, {
    namespace = var.target_namespace
  })
}
