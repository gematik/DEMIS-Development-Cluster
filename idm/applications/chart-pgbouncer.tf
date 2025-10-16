locals {
  pgbouncer_name = "pgbouncer"
  # Verify whether the service is defined or the deployment is explicitly enabled
  pgbouncer_enabled = contains(local.service_names, local.pgbouncer_name) ? var.deployment_information[local.pgbouncer_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  pgbouncer_template_app   = fileexists("${var.external_chart_path}/${local.pgbouncer_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.pgbouncer_name}/${local.application_values_file}" : "${path.module}/${local.pgbouncer_name}/${local.application_values_file}"
  pgbouncer_template_istio = fileexists("${var.external_chart_path}/${local.pgbouncer_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.pgbouncer_name}/${local.istio_values_file}" : "${path.module}/${local.pgbouncer_name}/${local.istio_values_file}"
  # Define override for resources
  pgbouncer_resources_overrides = try(var.resource_definitions[local.pgbouncer_name], {})
  pgbouncer_replicas            = lookup(local.pgbouncer_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.pgbouncer_name].replicas : null
  pgbouncer_resource_block      = lookup(local.pgbouncer_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.pgbouncer_name].resource_block : null
}

module "pgbouncer" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.pgbouncer_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pgbouncer_name
  deployment_information = var.deployment_information[local.pgbouncer_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.postgres[0]]

  # Pass the values for the chart
  application_values = templatefile(local.pgbouncer_template_app, {
    image_pull_secrets           = var.pull_secrets,
    repository                   = var.docker_registry,
    database_host                = var.database_target_host,
    istio_enable                 = var.istio_enabled,
    replica_count                = local.pgbouncer_replicas,
    resource_block               = local.pgbouncer_resource_block
    keycloak_db_enabled          = local.keycloak_enabled
    bundid_db_enabled            = local.bundid_enabled
    postgres_tls_secret_checksum = try(kubernetes_secret.postgresql_tls_certificates.metadata[0].annotations["checksum"], ""),
    userlist_secret_checksum     = try(kubernetes_secret.pgbouncer_userlist.metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.pgbouncer_template_istio, {
    namespace = var.target_namespace
  })
}
