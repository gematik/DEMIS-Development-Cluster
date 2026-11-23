locals {
  pgbouncer_name = "pgbouncer"
  # Entry point of the clients (Grafana, Audit Log Service)
  pgbouncer_host = "${local.pgbouncer_name}.${var.target_namespace}.svc.cluster.local"
}

# Connection pool in front of postgres
module "pgbouncer" {
  source = "../../modules/helm_deployment"

  count = local.postgres_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.pgbouncer_name
  deployment_information = var.deployment_information[local.pgbouncer_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.pgbouncer_name].app_template, {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.pull_secrets
    database_host      = "${local.postgres_name}.${var.target_namespace}.svc.cluster.local"
    port               = local.postgres_port
    # Restart on changed userlist or certificates
    secret_checksum = nonsensitive(sha256(jsonencode([local.userlist_content, local.postgresql_tls_certificates_data])))
    # Replicas, resources and sidecar resources (resources.tfvars)
    replica_count         = var.resource_definitions[local.pgbouncer_name].replicas
    resource_block        = var.resource_definitions[local.pgbouncer_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.pgbouncer_name].istio_proxy_resources
  }), local.chart_files[local.pgbouncer_name].app_values_override])

  istio_values = compact([templatefile(local.chart_files[local.pgbouncer_name].istio_template, {
    app_name  = local.pgbouncer_name
    namespace = var.target_namespace
    port      = local.postgres_port
  }), local.chart_files[local.pgbouncer_name].istio_values_override])

  depends_on = [module.postgres, kubernetes_secret_v1.pgbouncer_userlist]
}
