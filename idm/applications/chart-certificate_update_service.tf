locals {
  cus_name = "certificate-update-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  cus_enabled = contains(local.service_names, local.cus_name) ? var.deployment_information[local.cus_name].enabled : false
}

module "certificate_update_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.cus_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.cus_name
  deployment_information = var.deployment_information[local.cus_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.keycloak[0], module.redis_cus[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.cus_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    debug_enable          = var.debug_enabled,
    istio_enable          = var.istio_enabled,
    suspend               = var.certificate_update_service_suspend,
    cron_schedule         = var.certificate_update_cron_schedule,
    redis_user            = var.redis_cus_writer_user,
    keycloak_admin        = var.keycloak_admin_user,
    feature_flags         = try(var.feature_flags[local.cus_name], {}),
    config_options        = try(var.config_options[local.cus_name], {}),
    replica_count         = var.resource_definitions[local.cus_name].replicas,
    resource_block        = var.resource_definitions[local.cus_name].resource_block,
    istio_proxy_resources = var.resource_definitions[local.cus_name].istio_proxy_resources,
  }), local.chart_files[local.cus_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.cus_name].istio_template, {
    namespace = var.target_namespace
  }), local.chart_files[local.cus_name].istio_values_override])
}
