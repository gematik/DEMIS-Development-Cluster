locals {
  pseudo_name = "pseudonymization-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  pseudo_enabled = contains(local.service_names, local.pseudo_name) ? var.deployment_information[local.pseudo_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  pseudo_template_app   = fileexists("${var.external_chart_path}/${local.pseudo_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.pseudo_name}/${local.application_values_file}" : "${path.module}/${local.pseudo_name}/${local.application_values_file}"
  pseudo_template_istio = fileexists("${var.external_chart_path}/${local.pseudo_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.pseudo_name}/${local.istio_values_file}" : "${path.module}/${local.pseudo_name}/${local.istio_values_file}"
  # Define override for resources
  pseudo_resources_overrides = try(var.resource_definitions[local.pseudo_name], {})
  pseudo_replicas            = lookup(local.pseudo_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.pseudo_name].replicas : null
  pseudo_resource_block      = lookup(local.pseudo_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.pseudo_name].resource_block : null

  pseudo_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "pseudo-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "pseudonymization_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.pseudo_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pseudo_name
  deployment_information = var.deployment_information[local.pseudo_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0]]

  # Pass the values for the chart
  application_values = templatefile(local.pseudo_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    feature_flags                                      = try(var.feature_flags[local.pseudo_name], {}),
    config_options                                     = try(var.config_options[local.pseudo_name], {}),
    replica_count                                      = local.pseudo_replicas,
    resource_block                                     = local.pseudo_resource_block,
    db_secret_checksum                                 = try(kubernetes_secret_v1.database_credentials[local.pseudo_index].metadata[0].annotations["checksum"], "")
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.pseudo_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.pseudo_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.pseudo_template_istio, {
    namespace = var.target_namespace
  })
}
