locals {
  portal_igs_name = "portal-igs"
  # Verify whether the service is defined or the deployment is explicitly enabled
  portal_igs_enabled = contains(local.service_names, local.portal_igs_name) ? var.deployment_information[local.portal_igs_name].enabled : false
}

module "portal_igs" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.portal_igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.portal_igs_name
  deployment_information = var.deployment_information[local.portal_igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.gateway_igs[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.portal_igs_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    istio_enable          = var.istio_enabled,
    context_path          = var.context_path,
    csp_hostname          = "https://${var.portal_hostname}/ https://${var.meldung_hostname}/ https://${var.auth_hostname}/ https://${var.storage_hostname}/",
    feature_flags         = try(var.feature_flags[local.portal_igs_name], {}),
    config_options        = try(var.config_options[local.portal_igs_name], {}),
    replica_count         = var.resource_definitions[local.portal_igs_name].replicas,
    resource_block        = var.resource_definitions[local.portal_igs_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.portal_igs_name].istio_proxy_resources
    mf_logging_disabled   = !var.mf_logging_enabled
  }), local.chart_files[local.portal_igs_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.portal_igs_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    portal_hostnames           = local.frontend_hostnames
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.portal_igs_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.portal_igs_name], [])
  }), local.chart_files[local.portal_igs_name].istio_values_override])
}
