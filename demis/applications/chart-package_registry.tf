locals {
  fpr_name = "package-registry"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fpr_enabled = contains(local.service_names, local.fpr_name) ? var.deployment_information[local.fpr_name].enabled : false
}

module "package_registry" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.fpr_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.fpr_name
  deployment_information = var.deployment_information[local.fpr_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.fpr_name].app_template, {
    image_pull_secrets         = var.pull_secrets,
    repository                 = var.docker_registry,
    debug_enable               = var.debug_enabled,
    istio_enable               = var.istio_enabled,
    feature_flags              = try(var.feature_flags[local.fpr_name], {}),
    config_options             = try(var.config_options[local.fpr_name], {}),
    replica_count              = var.resource_definitions[local.fpr_name].replicas,
    resource_block             = var.resource_definitions[local.fpr_name].resource_block
    istio_proxy_resources      = var.resource_definitions[local.fpr_name].istio_proxy_resources,
    service_accounts_checksums = [for k, v in kubernetes_secret_v1.service_accounts : v.metadata[0].annotations["checksum"]]

  }), local.chart_files[local.fpr_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.fpr_name].istio_template, {
    namespace                = var.target_namespace
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.fpr_name], null)
  }), local.chart_files[local.fpr_name].istio_values_override])
}
