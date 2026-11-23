# Grafana: own module in the grafana folder (chart, dashboards, datasources)
locals {
  grafana_name = "grafana"
  # Enable only if explicitly set (active-versions.yaml)
  grafana_deployment_information = try(var.deployment_information[local.grafana_name], { main = { version = "0.0.0" }, enabled = false })
  grafana_enabled                = try(local.grafana_deployment_information.enabled, false)
  # Database credential of the Grafana reader (datasource on fetched_notifications)
  grafana_reader_credential = try([for cred in var.database_credentials : cred if cred.secret-name == "fetched-notifications-grafana-reader-database-secret"][0], null)
}

# Istio version of the cluster (istiod of the infrastructure), selects the matching Istio dashboards
data "kubernetes_resource" "istiod" {
  count       = local.grafana_enabled ? 1 : 0
  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name      = "istiod"
    namespace = "istio-system"
  }
}

module "grafana" {
  source = "./grafana"

  # Enable only if explicitly set
  count = local.grafana_enabled ? 1 : 0

  target_namespace     = var.target_namespace
  grafana_version      = coalesce(try(local.grafana_deployment_information.canary.version, null), local.grafana_deployment_information.main.version)
  grafana_digest       = try(local.grafana_deployment_information.canary.version, null) != null ? local.grafana_deployment_information.canary.image-digest : local.grafana_deployment_information.main.image-digest
  resource_definitions = { grafana = try(var.resource_definitions[local.grafana_name], {}) }
  # Used for downloading the Dashboards
  istio_version = data.kubernetes_resource.istiod[0].object.metadata.labels["app.kubernetes.io/version"]
  # Prometheus datasource and dashboards only with the Prometheus of this namespace (local); an external one is for Kiali only
  prometheus_enabled     = local.prometheus_enabled
  prometheus_service_url = local.prometheus_enabled ? local.prometheus_service_url : ""
  # Loki datasource only if Loki is deployed
  loki_enabled     = local.loki_enabled
  loki_service_url = local.loki_enabled ? module.loki[0].loki_service_url : ""
  # Audit Log data (fetched_notifications) via pgbouncer, read-only
  fetched_notifications_datasource = local.postgres_enabled && local.grafana_reader_credential != null ? {
    host                = local.pgbouncer_host
    port                = local.postgres_port
    secret_name         = local.grafana_reader_credential.secret-name
    secret_key_user     = local.grafana_reader_credential.secret-key-user
    secret_key_password = local.grafana_reader_credential.secret-key-password
  } : null

  # Loki and pgbouncer must exist before Grafana so its datasources resolve on first start
  depends_on = [helm_release.prometheus, module.loki, module.pgbouncer]
}
