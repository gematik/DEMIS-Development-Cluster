locals {
  # Enabled together with pgbouncer in the active-versions.yaml
  postgres_enabled = try(var.deployment_information["postgres"].enabled, false) && try(var.deployment_information["pgbouncer"].enabled, false)

  postgres_name = "postgres"
  # Port of postgres and pgbouncer
  postgres_port = 5432
}

# Database of the namespace (fetched_notifications of the Audit Log Service)
module "postgres" {
  source = "../../modules/helm_deployment"

  count = local.postgres_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.postgres_name
  deployment_information = var.deployment_information[local.postgres_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.postgres_name].app_template, {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.pull_secrets
    volume_claim       = var.volume_claims["postgres-volume-claim"]
    # Restart on changed credentials or certificates
    secret_checksum = nonsensitive(sha256(jsonencode([var.database_credentials, local.postgresql_tls_certificates_data])))
    # Replicas, resources and sidecar resources (resources.tfvars)
    replica_count         = var.resource_definitions[local.postgres_name].replicas
    resource_block        = var.resource_definitions[local.postgres_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.postgres_name].istio_proxy_resources
    # Feature flags and config options (feature_flags.tfvars, config_options.tfvars)
    feature_flags  = lookup(var.feature_flags, local.postgres_name, {})
    config_options = lookup(var.config_options, local.postgres_name, {})
  }), local.chart_files[local.postgres_name].app_values_override])

  istio_values = compact([templatefile(local.chart_files[local.postgres_name].istio_template, {
    app_name  = local.postgres_name
    namespace = var.target_namespace
    port      = local.postgres_port
  }), local.chart_files[local.postgres_name].istio_values_override])

  # The chart reads the secrets by name
  depends_on = [kubernetes_secret_v1.database_credentials, kubernetes_secret_v1.postgresql_tls_certificates]
}
