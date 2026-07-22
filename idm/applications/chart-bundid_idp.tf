locals {
  bundid_name = "bundid-idp"
  # Verify whether the service is defined or the deployment is explicitly enabled
  bundid_enabled = contains(local.service_names, local.bundid_name) ? var.deployment_information[local.bundid_name].enabled : false
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
  application_values = compact([templatefile(local.chart_files[local.bundid_name].app_template, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    namespace             = var.target_namespace,
    istio_enable          = var.istio_enabled,
    issuer_hostname       = local.bundid_idp_hostname,
    data_version          = local.stage_configuration_data_version,
    data_name             = local.stage_configuration_data_name,
    feature_flags         = try(var.feature_flags[local.bundid_name], {}),
    config_options        = try(var.config_options[local.bundid_name], {}),
    replica_count         = var.resource_definitions[local.bundid_name].replicas,
    resource_block        = var.resource_definitions[local.bundid_name].resource_block,
    enable_import         = var.bundid_idp_user_import_enabled
    istio_proxy_resources = var.resource_definitions[local.bundid_name].istio_proxy_resources
  }), local.chart_files[local.bundid_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.bundid_name].istio_template, {
    namespace                  = var.target_namespace,
    cluster_gateway            = var.cluster_gateway,
    issuer_hostname            = local.bundid_idp_hostname
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.bundid_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.bundid_name], [])
  }), local.chart_files[local.bundid_name].istio_values_override])
}
