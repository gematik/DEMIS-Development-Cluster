locals {
  kup_name = "keycloak-user-purger"
  # Verify whether the service is defined or the deployment is explicitly enabled
  kup_enabled = contains(local.service_names, local.kup_name) ? var.deployment_information[local.kup_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  kup_template_app   = fileexists("${var.external_chart_path}/${local.kup_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.kup_name}/${local.application_values_file}" : "${path.module}/${local.kup_name}/${local.application_values_file}"
  kup_template_istio = fileexists("${var.external_chart_path}/${local.kup_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.kup_name}/${local.istio_values_file}" : "${path.module}/${local.kup_name}/${local.istio_values_file}"
  # Define override for resources
  kup_resources_overrides = try(var.resource_definitions[local.kup_name], {})
  kup_replicas            = lookup(local.kup_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.kup_name].replicas : null
  kup_resource_block      = lookup(local.kup_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.kup_name].resource_block : null
}

module "keycloak_user_purger" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.kup_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.kup_name
  deployment_information = var.deployment_information[local.kup_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.keycloak[0]]

  # Pass the values for the chart
  application_values = templatefile(local.kup_template_app, {
    image_pull_secrets         = var.pull_secrets,
    repository                 = var.docker_registry,
    namespace                  = var.target_namespace,
    debug_enable               = var.debug_enabled,
    istio_enable               = var.istio_enabled,
    suspend                    = var.keycloak_user_purger_suspend,
    cron_schedule              = var.keycloak_user_purger_cron_schedule,
    keycloak_portal_admin_user = var.keycloak_portal_admin_user,
    keycloak_portal_client_id  = var.keycloak_portal_client_id,
    feature_flags              = try(var.feature_flags[local.kup_name], {}),
    config_options             = try(var.config_options[local.kup_name], {}),
    replica_count              = local.kup_replicas,
    resource_block             = local.kup_resource_block
  })
  istio_values = templatefile(local.kup_template_istio, {
    namespace = var.target_namespace
  })
}
