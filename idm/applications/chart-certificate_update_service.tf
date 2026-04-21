locals {
  cus_name = "certificate-update-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  cus_enabled = contains(local.service_names, local.cus_name) ? var.deployment_information[local.cus_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  cus_template_app   = fileexists("${var.external_chart_path}/${local.cus_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.cus_name}/${local.application_values_file}" : "${path.module}/${local.cus_name}/${local.application_values_file}"
  cus_template_istio = fileexists("${var.external_chart_path}/${local.cus_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.cus_name}/${local.istio_values_file}" : "${path.module}/${local.cus_name}/${local.istio_values_file}"
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
  application_values = templatefile(local.cus_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    suspend                                            = var.certificate_update_service_suspend,
    cron_schedule                                      = var.certificate_update_cron_schedule,
    redis_user                                         = var.redis_cus_writer_user,
    keycloak_admin                                     = var.keycloak_admin_user,
    feature_flags                                      = try(var.feature_flags[local.cus_name], {}),
    config_options                                     = try(var.config_options[local.cus_name], {}),
    replica_count                                      = var.resource_definitions[local.cus_name].replicas,
    resource_block                                     = var.resource_definitions[local.cus_name].resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.cus_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false),
    istio_proxy_resources                              = var.resource_definitions[local.cus_name].istio_proxy_resources,
  })
  istio_values = templatefile(local.cus_template_istio, {
    namespace = var.target_namespace
  })
}
