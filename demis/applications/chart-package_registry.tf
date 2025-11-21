locals {
  fpr_name = "package-registry"
  # Verify whether the service is defined or the deployment is explicitly enabled
  fpr_enabled = contains(local.service_names, local.fpr_name) ? var.deployment_information[local.fpr_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  fpr_template_app   = fileexists("${var.external_chart_path}/${local.fpr_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.fpr_name}/${local.application_values_file}" : "${path.module}/${local.fpr_name}/${local.application_values_file}"
  fpr_template_istio = fileexists("${var.external_chart_path}/${local.fpr_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.fpr_name}/${local.istio_values_file}" : "${path.module}/${local.fpr_name}/${local.istio_values_file}"
  # Define override for resources
  fpr_resources_overrides = try(var.resource_definitions[local.fpr_name], {})
  fpr_replicas            = lookup(local.fpr_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.fpr_name].replicas : null
  fpr_resource_block      = lookup(local.fpr_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.fpr_name].resource_block : null
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
  application_values = templatefile(local.fpr_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    feature_flags                                      = try(var.feature_flags[local.fpr_name], {}),
    config_options                                     = try(var.config_options[local.fpr_name], {}),
    replica_count                                      = local.fpr_replicas,
    resource_block                                     = local.fpr_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.fpr_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.fpr_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    service_accounts_checksums                         = [for k, v in kubernetes_secret.service_accounts : v.metadata[0].annotations["checksum"]]

  })
  istio_values = templatefile(local.fpr_template_istio, {
    namespace = var.target_namespace
  })
}
