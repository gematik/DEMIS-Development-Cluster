locals {
  keycloak_name           = "keycloak"
  tsl_deliverer_mock_name = "tsl-deliverer-mock"
  # Verify whether the service is defined or the deployment is explicitly enabled
  keycloak_enabled = contains(local.service_names, local.keycloak_name) ? var.deployment_information[local.keycloak_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  keycloak_template_app   = fileexists("${var.external_chart_path}/${local.keycloak_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.keycloak_name}/${local.application_values_file}" : "${path.module}/${local.keycloak_name}/${local.application_values_file}"
  keycloak_template_istio = fileexists("${var.external_chart_path}/${local.keycloak_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.keycloak_name}/${local.istio_values_file}" : "${path.module}/${local.keycloak_name}/${local.istio_values_file}"
  # Define override for resources
  keycloak_resources_overrides = try(var.resource_definitions[local.keycloak_name], {})
  keycloak_replicas            = lookup(local.keycloak_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.keycloak_name].replicas : null
  keycloak_resource_block      = lookup(local.keycloak_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.keycloak_name].resource_block : null

  # Determine whether to enable the TSL Deliverer Mock based on existence of tsl_deliverer_mock in deployment_information
  enable_tsl_deliverer_mock = try(contains(keys(var.deployment_information), local.tsl_deliverer_mock_name) ? var.deployment_information[local.tsl_deliverer_mock_name].enabled : false, false)

  # Fixed version with error handling and proper attribute reference
  keycloak_index = try(
    index(
      [for cred in var.database_credentials : cred.secret-name],
      "${local.keycloak_name}-database-secret"
    ),
    -1 # Default index if not found
  )
}

module "keycloak" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.keycloak_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.keycloak_name
  deployment_information = var.deployment_information[local.keycloak_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.pgbouncer[0], module.gematik_idp[0]]

  # Pass the values for the chart
  application_values = templatefile(local.keycloak_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    namespace                                          = var.target_namespace,
    istio_enable                                       = var.istio_enabled,
    local_stage                                        = var.is_local_mode,
    issuer_hostname                                    = local.auth_hostname,
    data_version                                       = local.stage_configuration_data_version,
    data_name                                          = local.stage_configuration_data_name,
    tsl_deliverer_mock_name                            = local.tsl_deliverer_mock_name,
    tsl_deliverer_mock_version                         = local.tsl_deliverer_mock_version
    feature_flags                                      = try(var.feature_flags[local.keycloak_name], {}),
    config_options                                     = try(var.config_options[local.keycloak_name], {}),
    replica_count                                      = local.keycloak_replicas,
    resource_block                                     = local.keycloak_resource_block,
    enable_import                                      = var.keycloak_user_import_enabled,
    enable_tsl_deliverer_mock                          = local.enable_tsl_deliverer_mock,
    tsl_download_endpoint                              = var.tsl_download_endpoint,
    keycloak_admin_account_checksum                    = try(kubernetes_secret_v1.keycloak_admin_account.metadata[0].annotations["checksum"], ""),
    keycloak_portal_secret_checksum                    = try(kubernetes_secret_v1.keycloak_portal_secret.metadata[0].annotations["checksum"], ""),
    keycloak_truststore_file_checksum                  = try(kubernetes_secret_v1.keycloak_truststore_file.metadata[0].annotations["checksum"], ""),
    keycloak_truststore_password_checksum              = try(kubernetes_secret_v1.keycloak_truststore_password.metadata[0].annotations["checksum"], ""),
    db_secret_checksum                                 = try(kubernetes_secret_v1.database_credentials[local.keycloak_index].metadata[0].annotations["checksum"], "")
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.keycloak_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.keycloak_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.keycloak_template_istio, {
    namespace                = var.target_namespace,
    cluster_gateway          = var.cluster_gateway,
    issuer_hostname          = local.auth_hostname,
    core_hostname            = local.core_hostname
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.keycloak_name], null)
  })
}
