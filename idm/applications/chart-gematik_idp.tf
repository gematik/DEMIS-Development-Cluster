locals {
  gemidp_name = "gematik-idp"
  # Verify whether the service is defined or the deployment is explicitly enabled
  gemidp_enabled = contains(local.service_names, local.gemidp_name) ? var.deployment_information[local.gemidp_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  gemidp_template_app   = fileexists("${var.external_chart_path}/${local.gemidp_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.gemidp_name}/${local.application_values_file}" : "${path.module}/${local.gemidp_name}/${local.application_values_file}"
  gemidp_template_istio = fileexists("${var.external_chart_path}/${local.gemidp_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.gemidp_name}/${local.istio_values_file}" : "${path.module}/${local.gemidp_name}/${local.istio_values_file}"
}

module "gematik_idp" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.gemidp_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.gemidp_name
  deployment_information = var.deployment_information[local.gemidp_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.gemidp_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    serverUrl                                          = var.ti_idp_server_url,
    clientName                                         = var.ti_idp_client_name,
    redirectUri                                        = var.ti_idp_redirect_uri,
    returnSsoToken                                     = var.ti_idp_return_sso_token,
    replica_count                                      = var.resource_definitions[local.gemidp_name].replicas,
    resource_block                                     = var.resource_definitions[local.gemidp_name].resource_block,
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.gemidp_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false),
    istio_proxy_resources                              = var.resource_definitions[local.gemidp_name].istio_proxy_resources,
  })
  istio_values = templatefile(local.gemidp_template_istio, {
    namespace                  = var.target_namespace,
    cluster_gateway            = var.cluster_gateway,
    ti_idp_hostname            = local.ti_idp_hostname
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.gemidp_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.gemidp_name], [])
  })

}
